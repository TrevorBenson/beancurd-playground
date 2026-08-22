# Testing

Demonstrates Terraform/OpenTofu's native testing framework - `.tftest.hcl`
files run via `terraform test`, distinct from the plan/apply-time
`check`/`precondition`/`postcondition` mechanisms used throughout the rest
of this repo.

- [`01-terraform-test-framework/`](01-terraform-test-framework) - a
  `variable` with its own `validation {}` rule, tested by two independent
  `run` blocks: one asserting a valid input plans successfully, one using
  `expect_failures` to assert an invalid input is rejected by that specific
  validation rule.
