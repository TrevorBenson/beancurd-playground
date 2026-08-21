# Ephemeral resource: valid response, accessing a JSON key

Fetches `https://jsonplaceholder.typicode.com/todos/1` (the same
known-fixed endpoint used in [`04-data-http-json-key`](../../04-data-http-json-key),
but via the `magodo/restful` provider's `ephemeral "restful_resource"`
instead of `data "http"`) and accesses the `title` and `completed` keys from
its JSON response.

Requires Terraform/OpenTofu >= 1.10 and real network access.

## Why a child module?

Root modules are **not allowed** to declare `output` blocks with
`ephemeral = true` - ephemeral values can only flow through non-root module
outputs or into other ephemeral-aware contexts (another ephemeral resource,
a `precondition`/`postcondition`, a write-only resource argument, etc.).

So the ephemeral resource + its ephemeral outputs live in
[`modules/todo-fetcher`](modules/todo-fetcher), and the root module's `check`
blocks consume `module.todo.title` / `module.todo.completed` to prove the
values were actually read - `check` conditions are allowed to reference
ephemeral values.

## Files

- `modules/todo-fetcher/main.tf` - `ephemeral "restful_resource" "item"`
  (GET `var.path`), with `output "title"` and `output "completed"` both
  marked `ephemeral = true`.
- `main.tf` - calls the module with `path = "/todos/1"`, then asserts on
  `module.todo.title` / `module.todo.completed` inside `check` blocks.

## How to test

```bash
terraform init
terraform plan
```

Expect log lines showing the ephemeral resource being opened and closed,
and a clean `No changes.` plan with no `check` warnings:

```
module.todo.ephemeral.restful_resource.item: Opening...
module.todo.ephemeral.restful_resource.item: Open complete after 0s
module.todo.ephemeral.restful_resource.item: Closing...
module.todo.ephemeral.restful_resource.item: Close complete after 0s

No changes. Your infrastructure matches the configuration.
```

If you change one of the `check` block conditions to something wrong (e.g.
`module.todo.completed == true`), the plan still succeeds (checks only
warn) but prints:

```
Warning: Check block assertion failed
```

along with the static `error_message` - note the message intentionally does
**not** interpolate the ephemeral value itself. If you try to, OpenTofu
replaces the whole custom message with a generic warning
(`Error message refers to ephemeral values`) rather than leak the ephemeral
value into plan output/logs.
