# `data "http"` - fetch and decode a known JSON payload

Demonstrates the `hashicorp/http` provider's `data "http"` source hitting a
real, stable endpoint that returns a **known, fixed** JSON body, then
decoding it with `jsondecode()` and accessing a known key.

This example requires real network access (a live GET request to
`jsonplaceholder.typicode.com`, a free, widely-used fake-REST-API for
examples/tutorials). Per this repo's convention, external dependencies are
only used when the concept itself demands it - parsing a genuine HTTP JSON
response is exactly that case.

## Files

- `main.tf` - `data "http" "todo"` requests
  `https://jsonplaceholder.typicode.com/todos/1`, which always returns:
  ```json
  {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
  ```
  `local.todo = jsondecode(data.http.todo.response_body)` decodes it, and
  outputs pull out the `title` and `completed` keys.

## How to test

```bash
terraform init
terraform plan
```

Requires outbound internet access. Expect:

```
todo_completed   = false
todo_status_code = 200
todo_title       = "delectus aut autem"
```

See [`02-precondition-validation`](../02-precondition-validation)
for a variant that adds variable validation against this same response via a
`lifecycle` precondition.
