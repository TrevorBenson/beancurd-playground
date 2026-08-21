# Variable validation

Demonstrates a `variable` block's own `validation {}` rule: input is
rejected the moment OpenTofu/Terraform tries to build a plan, before any
resource, data source, or `check`/`precondition` is even evaluated. No
provider or real infrastructure is used.

Contrast with [`03-locals-precondition`](../03-locals-precondition) (a
`lifecycle precondition` fails only once the resource it's attached to is
evaluated) and [`01-check-block-warning`](../01-check-block-warning) (a
failed `check` never blocks the plan at all). `validation` sits at the
strict end: wrong input, no plan.

## Files

- `main.tf` - `variable "environment"` (no default - you must supply one)
  with a `validation` block restricting it to `dev`, `staging`, or
  `production`.

## How to test

```bash
terraform init
terraform plan -var environment=bogus
```

Expect a plan-time failure before OpenTofu even attempts to read/refresh
anything:

```
Error: Invalid value for variable
...
environment must be one of: dev, staging, production.

This was checked by the validation rule at main.tf:6,3-13.
```

Now supply a valid value:

```bash
terraform plan -var environment=staging
```

The plan succeeds and shows `environment = "staging"` as an output.
