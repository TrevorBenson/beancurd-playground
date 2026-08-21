# Comparing two locals in a lifecycle precondition

Demonstrates a `lifecycle { precondition {} }` block that compares two
`local` values and hard-fails the plan when they disagree. Contrast with
[`01-plan-check-warning`](../01-plan-check-warning), where a failed assertion
only warns - a failed `precondition` stops the plan/apply entirely.

Uses the built-in `terraform_data` resource (part of the implicit
`terraform.io/builtin/terraform` provider) purely as a place to attach the
`lifecycle` block - no external provider or real infrastructure involved.

## Files

- `main.tf` - `local.expected_replica_count` (a "policy" value derived from
  `var.environment`) compared against `local.actual_replica_count` (from
  `var.actual_replica_count`) inside a `precondition` on
  `terraform_data.replica_count_check`.

## How to test

```bash
terraform init
terraform plan
```

With the defaults (`environment = "production"` → expects `3` replicas,
`actual_replica_count = 1`), the plan **fails**:

```
Error: Resource precondition failed
...
actual_replica_count (1) does not match the expected_replica_count (3) for
environment 'production'.
```

Now satisfy the precondition:

```bash
terraform plan -var actual_replica_count=3
```

The plan succeeds and shows `terraform_data.replica_count_check` to be
created. You can `terraform apply` this - it creates no real infrastructure.

Try a non-production environment too:

```bash
terraform plan -var environment=staging -var actual_replica_count=1
```

This also succeeds, since `expected_replica_count` for anything other than
`production` is `1`.
