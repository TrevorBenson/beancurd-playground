# Variable validation against an ephemeral response via a lifecycle precondition

Extends [`01-valid-response`](../01-valid-response):
fetches the same fixed JSON body via `ephemeral "restful_resource"`, then
uses a `lifecycle { precondition {} }` to validate a variable against a key
in the *actual* ephemeral response, invalidating the plan when it doesn't
match.

Requires Terraform/OpenTofu >= 1.10 and real network access to
`jsonplaceholder.typicode.com`.

## Why a child module, and why the precondition lives on the output

Two of the constraints from the earlier examples combine here:

- Root modules can't declare `ephemeral = true` outputs (see
  [`01-valid-response`](../01-valid-response)),
  so the ephemeral resource lives in
  [`modules/todo-fetcher`](modules/todo-fetcher).
- `self` (used to reference a block's own result) only works in
  `postcondition`, not `precondition` (see
  [`01-http-data-source/02-precondition-validation`](../../01-http-data-source/02-precondition-validation)),
  so the precondition is attached to the module's `output "title"` block,
  referencing `ephemeral.restful_resource.item.output.completed` directly
  rather than via `self`.

## Files

- `modules/todo-fetcher/main.tf` - `ephemeral "restful_resource" "item"`
  (GET `var.path`), plus `variable "expected_completed"` and an
  `output "title"` whose `precondition` asserts
  `ephemeral.restful_resource.item.output.completed == var.expected_completed`.
- `main.tf` - calls the module with `path = "/todos/1"` and
  `variable "expected_completed"` (default `true`, deliberately wrong - the
  live endpoint always returns `completed = false`).

## How to test

```bash
terraform init
terraform plan
```

With the default `expected_completed = true`, the plan **fails**:

```
Error: Module output value precondition failed
...
ephemeral.restful_resource.item.output.completed did not match
expected_completed (true).
```

Now satisfy the precondition with the value the endpoint actually returns:

```bash
terraform plan -var expected_completed=false
```

The plan succeeds with `No changes.`
