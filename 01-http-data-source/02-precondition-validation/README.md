# Variable validation against a `data "http"` response via a lifecycle precondition

Extends [`01-fetch-and-decode-json`](../01-fetch-and-decode-json): fetches the same
fixed JSON body, then uses a `lifecycle { precondition {} }` to validate a
variable against a value found in the *actual* response, invalidating the
plan when it doesn't match.

Requires real network access to `jsonplaceholder.typicode.com` (same
endpoint as example 4).

## A note on where the precondition lives

`self` (used to reference a block's own result) is only available in
`postcondition`, provisioner, and connection blocks - **not**
`precondition`. A precondition can only see values already known before the
block it's attached to runs, so it can't reference the `data "http"` source's
own freshly-fetched body via `self`. This example instead attaches the
`precondition` to the `output` block that consumes the parsed response,
which is exactly where the "validate what we fetched, and fail the plan if
it's wrong" logic belongs.

(If you want the precondition physically on the data source, use
`postcondition` there instead - functionally similar, but it's a
postcondition, not a precondition.)

## Files

- `main.tf` - `data "http" "todo"` (as in example 4), plus
  `variable "expected_todo_id"` (default `999`, deliberately wrong - the
  live endpoint always returns `id = 1`) and an `output "todo_title"` whose
  `precondition` asserts `local.todo.id == var.expected_todo_id`.

## How to test

```bash
terraform init
terraform plan
```

With the default `expected_todo_id = 999`, the plan **fails**:

```
Error: Module output value precondition failed
...
Fetched todo id (1) does not match expected_todo_id (999).
```

Now satisfy the precondition with the value the endpoint actually returns:

```bash
terraform plan -var expected_todo_id=1
```

The plan succeeds and shows `todo_title = "delectus aut autem"`.
