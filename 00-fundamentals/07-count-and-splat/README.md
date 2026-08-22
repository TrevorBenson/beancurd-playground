# `count` and splat expressions

Demonstrates the `count` meta-argument (creating N instances of a resource,
indexed `0..N-1`) and the `[*]` splat expression (collecting one attribute
from every instance into a single list). Uses the built-in `terraform_data`
resource - no external provider or real infrastructure involved.

## `count` vs `for_each`

Contrast with [`06-for-each-multiple-resources`](../06-for-each-multiple-resources):
`count` instances are addressed by *position* (`terraform_data.widget[0]`),
`for_each` instances are addressed by *key* (`terraform_data.widget["small_red"]`).
Removing an item from the middle of a `count` list shifts every later
index down by one, which Terraform sees as "destroy N, recreate N+1..." -
the exact churn problem `for_each` avoids. Prefer `for_each` whenever
instances have a natural stable key; reach for `count` when instances are
genuinely just "N copies of the same thing" with no meaningful identity of
their own (or for the simpler `count = condition ? 1 : 0` on/off pattern).

## Files

- `main.tf` - `variable "widget_names"` (a list, default 3 entries) and
  `resource "terraform_data" "widget"` with `count = length(var.widget_names)`,
  plus `output "widget_inputs_splat"` using `terraform_data.widget[*].input`.

## How to test

```bash
terraform init
terraform plan
```

Expect three instances (`terraform_data.widget[0]`, `[1]`, `[2]`) and:

```
Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + widget_inputs_splat = [
      + "alpha",
      + "beta",
      + "gamma",
    ]
```
