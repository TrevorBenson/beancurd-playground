# `for_each` over `data "http"` - fetch multiple known JSON payloads

Extends [`01-fetch-and-decode-json`](../01-fetch-and-decode-json) with
[`for_each`](../../00-fundamentals/06-for-each-multiple-resources): fetches
several fixed `jsonplaceholder.typicode.com/todos/<id>` responses in a
single plan, one `data "http"` instance per id.

Requires real network access (same endpoint family as the rest of this
tier).

## A note on `for_each`'s type requirement

`for_each` on a resource or data source only accepts a **map** or a **set
of strings** - not a set of numbers. `var.todo_ids` is declared as
`set(string)` (`["1", "2", "3"]`) even though the values represent numeric
ids, and `each.key` is interpolated directly into the URL.

## Files

- `main.tf` - `variable "todo_ids"` (default `["1", "2", "3"]`) and
  `data "http" "todo"` with `for_each = var.todo_ids`, decoded per-instance
  into `local.todos`.

## How to test

```bash
terraform init
terraform plan
```

Expect one `data.http.todo["N"]` read per id and a `todo_titles` output
with one entry per id:

```
data.http.todo["1"]: Reading...
data.http.todo["2"]: Reading...
data.http.todo["3"]: Reading...
data.http.todo["1"]: Read complete after 0s [id=https://jsonplaceholder.typicode.com/todos/1]
data.http.todo["2"]: Read complete after 0s [id=https://jsonplaceholder.typicode.com/todos/2]
data.http.todo["3"]: Read complete after 0s [id=https://jsonplaceholder.typicode.com/todos/3]

Changes to Outputs:
  + todo_titles = {
      + "1" = "delectus aut autem"
      + "2" = "quis ut nam facilis et officia qui"
      + "3" = "fugiat veniam minus"
    }
```

Try `terraform plan -var 'todo_ids=["1","4"]'` and note only the changed
set of ids is fetched/shown - unrelated ids from the previous plan aren't
carried over, since this is a data source (nothing persists between plans
regardless).
