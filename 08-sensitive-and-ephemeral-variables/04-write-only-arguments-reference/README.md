# Write-only arguments: the sanctioned path into real resources

[`03-ephemeral-context-limits`](../03-ephemeral-context-limits) showed that an ephemeral value can't be
assigned to an ordinary resource argument. **Write-only arguments**
(attributes whose name ends in `_wo`, a protocol feature added in
Terraform/OpenTofu 1.11) are the sanctioned exception: a provider can mark
a specific argument as write-only, meaning Terraform passes the value
through during apply but never stores it in state at all - the argument
exists purely to receive a value once, not to be diffed against later.

## Why this example only inspects a schema, and never applies anything

As of this writing, most zero-dependency providers already used in this
repo have **not** adopted write-only arguments: `hashicorp/local` (2.9.0),
`hashicorp/random` (3.9.0), and `hashicorp/tls` (4.3.0) had zero
`_wo`-suffixed attributes across every resource they define, at the
versions checked during research (verified with the same schema-scan
technique below). `hashicorp/vault` (5.11.0, already used elsewhere in
this tier) is the exception: it has actually adopted write-only arguments
extensively - roughly 36 resources, including
`vault_kv_secret_v2.data_json_wo`, the exact resource type this tier's own
`06-vault-dynamic-secrets` capstone uses as an `ephemeral` resource. None
of that, however, gives us a zero-dependency, no-credentials way to
inspect write-only arguments in *this* example, so we reach for
`hashicorp/aws` (~> 5.0) instead, which has adopted them on exactly the
fields you'd expect. This example downloads that provider purely to
read its schema - **no `provider "aws" {}` block, no credentials, no
resources, no live AWS API calls, ever.**

## Files

- `main.tf` - a bare `required_providers` block for `hashicorp/aws`,
  nothing else.

## How to test

```bash
terraform init
```

This step downloads the full `hashicorp/aws` provider plugin binary
(several hundred MB) - it's the only slow step here, and needs no AWS
credentials.

```bash
terraform providers schema -json > schema.json
python3 -c "
import json
d = json.load(open('schema.json'))
p = d['provider_schemas']['registry.opentofu.org/hashicorp/aws']
for name, sch in sorted(p.get('resource_schemas', {}).items()):
    attrs = sch['block'].get('attributes', {})
    wo = [a for a in attrs if a.endswith('_wo')]
    if wo:
        print(name, wo)
"
```

Expect exactly these 7 resources (attribute lists may grow in newer
provider versions, but these are what v5.x has at minimum):

```
aws_db_instance ['password_wo']
aws_docdb_cluster ['master_password_wo']
aws_rds_cluster ['master_password_wo']
aws_redshift_cluster ['master_password_wo']
aws_redshiftserverless_namespace ['admin_user_password_wo']
aws_secretsmanager_secret_version ['has_secret_string_wo', 'secret_string_wo']
aws_ssm_parameter ['has_value_wo', 'value_wo']
```

Now check the same question for the other providers already used elsewhere
in this repo - `hashicorp/vault` will report hits here, the other three
won't (adjust versions in the `python3` snippet's provider key if your
`.terraform.lock.hcl` pins differ):

```bash
python3 -c "
import json
d = json.load(open('schema.json'))
for prov in ['registry.opentofu.org/hashicorp/local', 'registry.opentofu.org/hashicorp/random', 'registry.opentofu.org/hashicorp/tls', 'registry.opentofu.org/hashicorp/vault']:
    if prov not in d['provider_schemas']:
        print(prov, '- not installed in this directory, skip')
        continue
    p = d['provider_schemas'][prov]
    hits = [n for n, s in p.get('resource_schemas', {}).items() if any(a.endswith('_wo') for a in s['block'].get('attributes', {}))]
    print(prov, '->', hits or 'no write-only attributes')
"
```

(This second check will report every provider as "not installed in this
directory" unless you also add them to `required_providers` and re-run
`terraform init` - that's expected; the point of this example is the
`hashicorp/aws` schema. The results for `local`/`random`/`tls`/`vault`
above were checked during this repo's research and are stated here as a
finding, not something this directory re-proves on every run; see
[`06-vault-dynamic-secrets`](../06-vault-dynamic-secrets) for `vault`'s
`_wo` attribute in actual use.)

## The conceptual pattern (not runnable here - needs real AWS)

```hcl
resource "aws_db_instance" "example" {
  # ... other required arguments ...
  password_wo         = var.ephemeral_db_password # an ephemeral variable
  password_wo_version = 1                          # bump this to force re-apply
}
```

Since a write-only value is never stored, Terraform has nothing to diff
the next plan against to know it changed. The paired `_wo_version`
argument (an arbitrary string or number you control) is what actually
signals "apply the new write-only value now" - bump it, and Terraform
re-sends whatever `password_wo` currently evaluates to.
