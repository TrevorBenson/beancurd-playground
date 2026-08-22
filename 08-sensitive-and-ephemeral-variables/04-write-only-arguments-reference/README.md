# Write-only arguments: the sanctioned path into real resources

`03-ephemeral-context-limits` showed that an ephemeral value can't be
assigned to an ordinary resource argument. **Write-only arguments**
(attributes whose name ends in `_wo`, a protocol feature added in
Terraform/OpenTofu 1.11) are the sanctioned exception: a provider can mark
a specific argument as write-only, meaning Terraform passes the value
through during apply but never stores it in state at all - the argument
exists purely to receive a value once, not to be diffed against later.

## Why this example only inspects a schema, and never applies anything

As of this writing, **no zero-dependency provider already used in this
repo has adopted a write-only argument**: `hashicorp/local` (2.9.0),
`hashicorp/random` (3.9.0), `hashicorp/tls` (4.3.0), and even
`hashicorp/vault` (up to 5.11.0) have zero `_wo`-suffixed attributes across
every resource they define - verified by the exact schema-scan technique
below, not assumed. `hashicorp/aws` (~> 5.0) has adopted them, on exactly
the fields you'd expect. This example downloads that provider purely to
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

Now confirm the negative claim for the providers already used elsewhere in
this repo (adjust versions in the `python3` snippet's provider key if your
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
`hashicorp/aws` schema, and the negative result for the others was
independently verified during this repo's research and is stated here as
a finding, not something this directory re-proves on every run.)

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
