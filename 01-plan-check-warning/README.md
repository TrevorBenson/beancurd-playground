# Check block with a plan-time warning

Demonstrates Terraform/OpenTofu's `check` block: an assertion that runs during
plan (and apply) but only ever produces a **warning**, never blocks the run.
This is the idiomatic way to implement a "soft" guardrail, as opposed to a
`lifecycle { precondition {} }`, which hard-fails the plan (see
[`03-locals-comparison-precondition`](../03-locals-comparison-precondition)).

No provider or real infrastructure is used - this is a pure language-feature
example.

## Files

- `main.tf` - a `variable "max_widgets"` (default `150`), a `local.soft_limit`
  of `100`, and a `check` block asserting `max_widgets <= soft_limit`.

## How to test

```bash
terraform init
terraform plan
```

With the default value (`150`), the plan **succeeds** but prints a yellow
`Warning: Check block assertion failed` pointing at the `check` block, along
with the custom `error_message`. Note there are no `Error` lines and the exit
code is still `0`.

Now try a value that satisfies the assertion:

```bash
terraform plan -var max_widgets=50
```

No warning is printed.

You can also `terraform apply` in either case - the check re-runs at apply
time and behaves the same way (warns but never blocks).
