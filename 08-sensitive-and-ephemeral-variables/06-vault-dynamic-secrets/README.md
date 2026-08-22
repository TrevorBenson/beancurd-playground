# Vault dynamic secrets: the flagship ephemeral use case

Fetches a real secret from a real, locally-running HashiCorp Vault
instance using `ephemeral "vault_kv_secret_v2"`, authenticating with a
Vault token that is itself both `sensitive` and `ephemeral` - the exact
combination demonstrated in
[`../05-combining-plain-sensitive-and-sensitive-ephemeral`](../05-combining-plain-sensitive-and-sensitive-ephemeral),
now feeding a real provider instead of a placeholder header.

## Prerequisites (the one example in this repo needing this)

You need the `vault` binary installed locally. In a **separate terminal**,
start a dev-mode server (in-memory, unseals itself, listens on localhost
only):

```bash
vault server -dev -dev-root-token-id="research-root-token" -dev-listen-address="127.0.0.1:8299"
```

Leave that running. **Before you run this**, check nothing else is
already using port 8299 (`ss -ltnp | grep 8299` or `lsof -i :8299`); if
something is, pick a different port, adjust the address consistently in
the `vault` commands below and in `terraform plan -var vault_addr=...`,
and never kill a process on that port that you didn't start yourself.

In another terminal, write a test secret:

```bash
export VAULT_ADDR="http://127.0.0.1:8299"
export VAULT_TOKEN="research-root-token"
vault kv put secret/research-app username="svc-account" password="some-secret-value"
```

## Files

- `main.tf` - `variable "vault_addr"` (defaults to the dev server above),
  `variable "vault_token"` (`sensitive = true` and `ephemeral = true`),
  `provider "vault"` configured with both, `ephemeral
  "vault_kv_secret_v2" "research_app"` fetching `secret/research-app`, and
  a `check` block asserting on the fetched `username`.

## How to test

```bash
terraform init
terraform plan -var 'vault_token=research-root-token'
```

Expect the ephemeral resource to open/close against your real local Vault,
and a clean plan:

```
ephemeral.vault_kv_secret_v2.research_app: Opening...
ephemeral.vault_kv_secret_v2.research_app: Open complete after 0s
ephemeral.vault_kv_secret_v2.research_app: Closing...
ephemeral.vault_kv_secret_v2.research_app: Close complete after 0s

No changes. Your infrastructure matches the configuration.
```

Apply it (re-supplying the token, per
[`../02-ephemeral-variable-basics`](../02-ephemeral-variable-basics)'s
finding that ephemeral variables must be given again at apply time):

```bash
terraform apply -auto-approve -var 'vault_token=research-root-token'
```

Confirm neither the token nor the fetched password ever touched state:

```bash
terraform show -json terraform.tfstate > state.json
grep -c "research-root-token\|some-secret-value" state.json || echo "0 - confirmed clean"
rm -f state.json
```

When you're done, stop the Vault dev server (`Ctrl+C` in its terminal) -
it's in-memory and forgets everything on exit.

## Beyond this example: enterprise auth patterns (reference only, not live-tested)

The `hashicorp/vault` provider (v5.11.0 at time of writing) ships **24
ephemeral resource types**, not just `vault_kv_secret_v2`:

```
vault_alicloud_access_credentials       vault_gcp_service_account_key
vault_approle_auth_backend_role_secret_id  vault_gcpkms_decrypt
vault_aws_access_credentials             vault_gcpkms_encrypt
vault_aws_static_access_credentials      vault_gcpkms_reencrypt
vault_azure_access_credentials           vault_gcpkms_sign
vault_azure_static_credentials           vault_generic_endpoint
vault_cf_auth_login                      vault_generic_secret
vault_database_secret                    vault_kerberos_auth_backend_login
vault_gcp_oauth2_access_token            vault_kubernetes_service_account_token
vault_kv_secret_v2                       vault_radius_auth_login
vault_spiffe_secret_backend_mintjwt      vault_terraform_token
vault_token                              vault_userpass_auth_login
```

(Verify this roster yourself: `terraform providers schema -json | python3 -c "import json,sys; d=json.load(sys.stdin); p=next(v for k,v in d['provider_schemas'].items() if k.endswith('hashicorp/vault')); print(sorted(p['ephemeral_resource_schemas'].keys()))"` after declaring the provider - no live Vault server needed just to read the schema. Matching on the `hashicorp/vault` suffix rather than a hardcoded registry hostname keeps this working whether you're running OpenTofu, which keys schemas under `registry.opentofu.org/...`, or HashiCorp Terraform, which uses `registry.terraform.io/...`.)

The `provider "vault" {}` block itself also has dedicated nested
authentication blocks - any of which can accept an ephemeral variable for
its credential arguments, exactly the way `token` did above:

```
auth_login              auth_login_jwt          auth_login_radius
auth_login_aws          auth_login_kerberos     auth_login_token_file
auth_login_azure        auth_login_oci          client_auth
auth_login_cert         auth_login_oidc         headers
auth_login_gcp          auth_login_userpass
```

For example, a Kerberos-authenticated provider might look like:

```hcl
provider "vault" {
  address = var.vault_addr

  auth_login_kerberos {
    username = var.eph_krb_username # ephemeral
    service  = "vault-service"
    # ... realm, keytab/password, etc.
  }
}
```

or an OIDC-authenticated one:

```hcl
provider "vault" {
  address = var.vault_addr

  auth_login_oidc {
    role = "my-oidc-role"
    # the OIDC flow itself opens a browser/callback listener - this isn't
    # a single ephemeral variable feeding a static argument the way token
    # or userpass auth is; it's an interactive login handled by the
    # provider itself
  }
}
```

**Why this repo doesn't live-test Kerberos, OIDC, or the other auth
methods:** each needs real supporting infrastructure this repo can't
provide - a Kerberos realm and KDC, a real OIDC identity provider, a real
AWS/Azure/GCP account for the cloud-credential ephemeral resources, and so
on. The *mechanism* is identical to what this example already proves end
-to-end: an ephemeral (and often also sensitive) variable feeds a
provider-level credential argument, per the allow-list established in
[`../03-ephemeral-context-limits`](../03-ephemeral-context-limits) - only
the credential-acquisition side changes per auth method. If you have
access to a real Vault Enterprise cluster with Kerberos or OIDC configured,
the pattern in this example's `main.tf` (an ephemeral, sensitive variable
feeding `provider "vault" {}`, followed by an `ephemeral` resource read)
transfers directly - only the `auth_login_*` block and its arguments
change.
