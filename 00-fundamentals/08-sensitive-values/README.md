# Sensitive variables and outputs

Demonstrates `sensitive = true` on a `variable` and on an `output`: OpenTofu
redacts the value from plan/apply console output (`(sensitive value)` /
`<sensitive>`) and from `terraform output`'s default table view. Uses the
built-in `terraform_data` resource - no external provider or real
infrastructure involved.

## The propagation rule

Once a value is marked sensitive, anything computed from it is sensitive
too - `terraform_data.config.output` (derived from `var.api_key`) can only
be assigned to an `output` block that itself declares `sensitive = true`.
Trying to expose a sensitive-derived value through a plain output is a
plan-time error, not a runtime leak - the mistake gets caught before
anything is ever displayed.

Note this is a *display/UI* safeguard, not encryption: sensitive values are
still written to the state file in plain text. Use a proper secrets
manager (and mark the corresponding attribute sensitive here) for anything
that actually needs to stay secret at rest.

## Files

- `main.tf` - `variable "api_key"` (`sensitive = true`), `resource
  "terraform_data" "config"` using it, `output "api_key_masked"`
  (`sensitive = true`), and `output "non_sensitive_note"` for contrast.

## How to test

```bash
terraform init
terraform apply -auto-approve
```

Expect the sensitive output redacted at both plan and apply time:

```
Changes to Outputs:
  + api_key_masked     = (sensitive value)
  + non_sensitive_note = "config created"
...
Outputs:

api_key_masked = <sensitive>
non_sensitive_note = "config created"
```

Running `terraform output` afterward shows the same redaction; only
`terraform output api_key_masked` (naming it explicitly) or `terraform
output -json` reveal the real value.

Clean up:

```bash
terraform destroy -auto-approve
```
