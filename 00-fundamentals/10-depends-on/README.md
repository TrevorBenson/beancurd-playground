# Explicit ordering with `depends_on`

Demonstrates `depends_on`: forcing an explicit creation order between two
resources that have no attribute reference between them (and therefore no
ordering Terraform would infer on its own). Uses the built-in
`terraform_data` resource - no external provider or real infrastructure
involved.

## Why this needs `depends_on` at all

`terraform_data.second`'s `input` is the literal string `"second"` - it
never reads anything from `terraform_data.first`, so Terraform has no
attribute-reference clue that `first` must exist before `second`. Without
`depends_on`, OpenTofu would be free to create them in either order (or in
parallel). Adding `depends_on = [terraform_data.first]` forces `first` to
be created before `second`, which is exactly the situation you're in when
one resource has a side effect the other genuinely requires but that
Terraform's dependency graph can't see from the config alone (e.g. an
IAM policy that must exist before a service that assumes it starts
enforcing access, with no attribute of the policy referenced directly).

Prefer an attribute reference over `depends_on` whenever one is available
- it documents *why* the ordering exists. Reach for `depends_on` only when
no such reference is possible.

## Files

- `main.tf` - `terraform_data.first`, then `terraform_data.second` with
  `depends_on = [terraform_data.first]`.

## How to test

```bash
terraform init
terraform apply -auto-approve
```

On this first apply, expect `first` to report "Creating..."/"Creation
complete" before `second`:

```
terraform_data.first: Creating...
terraform_data.first: Creation complete after 0s [id=...]
terraform_data.second: Creating...
terraform_data.second: Creation complete after 0s [id=...]
```

(Re-running `terraform apply` afterward is a no-op - `first` and `second`
already exist and match configuration, so neither creation sequence
prints. The ordering guarantee is only observable when the resources are
actually being created, or recreated after a forced replacement.)

Clean up:

```bash
terraform destroy -auto-approve
```
