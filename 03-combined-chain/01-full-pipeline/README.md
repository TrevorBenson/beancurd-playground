# Full pipeline: chaining every concept in this repo

A single capstone example wiring together every concept demonstrated
individually in the earlier tiers, around one shared `var.todo_id`:

1. **Variable validation** ([`00-fundamentals/04-variable-validation`](../../00-fundamentals/04-variable-validation)) -
   `var.todo_id` must be positive.
2. **`check` block warning** ([`00-fundamentals/01-check-block-warning`](../../00-fundamentals/01-check-block-warning)) -
   warns (doesn't block) if the fetched todo is already `completed`.
3. **`data "http"` + `jsondecode()`** ([`01-http-data-source/01-fetch-and-decode-json`](../../01-http-data-source/01-fetch-and-decode-json)) -
   fetches the todo over real HTTP.
4. **Output precondition** ([`01-http-data-source/02-precondition-validation`](../../01-http-data-source/02-precondition-validation)) -
   hard-fails the plan if the fetched title doesn't match `var.expected_title`.
5. **Ephemeral resource fetch** ([`02-ephemeral-resources/01-valid-response`](../../02-ephemeral-resources/01-valid-response)) -
   re-fetches the same todo via `ephemeral "restful_resource"`, never
   touching state.
6. **Postcondition with `self`** ([`00-fundamentals/05-postcondition-self`](../../00-fundamentals/05-postcondition-self)) -
   validates the ephemeral resource's own response id.

Requires Terraform/OpenTofu >= 1.10 and real network access to
`jsonplaceholder.typicode.com`.

## Files

- `main.tf` - `variable "todo_id"` (default `1`, validated `> 0`) and
  `variable "expected_title"` (default `"delectus aut autem"`, correct for
  `todo_id = 1`), a `data "http" "todo"` + `check` + `output` precondition
  block, and an `ephemeral "restful_resource" "todo"` with a postcondition.

## How to test

### 1. Everything passes (defaults)

```bash
terraform init
terraform plan
```

Expect a clean plan, no warnings or errors:

```
Changes to Outputs:
  + todo_title = "delectus aut autem"
```

### 2. Variable validation blocks the plan outright

```bash
terraform plan -var todo_id=0
```

```
Error: Invalid value for variable
...
todo_id must be a positive integer.
```

### 3. Output precondition fails (title mismatch)

```bash
terraform plan -var expected_title=bogus
```

```
Error: Module output value precondition failed
...
Fetched title 'delectus aut autem' did not match expected_title 'bogus'.
```

### 4. `check` block warns without blocking (todo already completed)

`jsonplaceholder.typicode.com/todos/4` is a fixed fixture with
`completed = true` and `title = "et porro tempora"`:

```bash
terraform plan -var todo_id=4 -var expected_title="et porro tempora"
```

The plan **succeeds** but prints:

```
Warning: Check block assertion failed
...
todo 4 is already marked completed - downstream automation may skip it.
```

Contrast steps 3 and 4: a wrong `expected_title` is a hard error (the
precondition path), but an already-completed todo only warns (the `check`
path) - the same shape of "something looks off" produces two different
severities depending on which mechanism guards it.
