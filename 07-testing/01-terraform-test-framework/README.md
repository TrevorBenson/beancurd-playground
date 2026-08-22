# The native `terraform test` framework

Demonstrates `.tftest.hcl` test files and the `terraform test` command:
Terraform/OpenTofu's built-in testing framework, distinct from every
`check`/`precondition`/`postcondition` example elsewhere in this repo,
which only validate *at plan/apply time against real config*. A `.tftest.hcl`
file runs a series of independent `run` blocks - each one plans (or
applies) the configuration with its own `variables`, then asserts things
about the result, without ever touching your real working directory's
state. No provider or real infrastructure is used.

## Files

- `main.tf` - the same `variable "environment"` + `validation {}` pattern
  from [`00-fundamentals/04-variable-validation`](../../00-fundamentals/04-variable-validation),
  reused here as the subject under test.
- `tests/environment.tftest.hcl` - two `run` blocks:
  - `accepts_valid_environment` - plans with `environment = "staging"` and
    asserts the output echoes it back.
  - `rejects_invalid_environment` - plans with `environment = "bogus"` and
    uses `expect_failures = [var.environment]` to assert that *this specific
    variable's validation* is what causes the plan to fail (not just "some
    error happened").

## How to test

```bash
terraform init
terraform test
```

Expect both runs to pass:

```
tests/environment.tftest.hcl... pass
  run "accepts_valid_environment"... pass
  run "rejects_invalid_environment"... pass

Success! 2 passed, 0 failed.
```

To see what a genuine test failure looks like, temporarily break the first
assertion (edit `tests/environment.tftest.hcl`, change
`output.environment == "staging"` to `output.environment == "wrong"`), then
re-run `terraform test`:

```
tests/environment.tftest.hcl... fail
  run "accepts_valid_environment"... fail

Error: Test assertion failed
...
    │ output.environment is "staging"
    ├────────────────
    │ Diff:
    │     "staging" -> "wrong"

environment output did not echo the input variable
  run "rejects_invalid_environment"... pass

Failure! 1 passed, 1 failed.
```

Revert the edit afterward so the example is left in its passing state.
