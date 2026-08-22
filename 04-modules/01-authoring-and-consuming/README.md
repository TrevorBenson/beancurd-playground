# Authoring and consuming a module

Demonstrates writing a minimal, reusable module (`modules/widget`, with its
own `variable`/`resource`/`output` blocks) and consuming it from the root
module with `for_each` - one module instance per map entry, addressed as
`module.widget["small_red"]` / `module.widget["large_blue"]`, exactly like
a `for_each` resource (see
[`00-fundamentals/06-for-each-multiple-resources`](../../00-fundamentals/06-for-each-multiple-resources)).
Uses the built-in `terraform_data` resource inside the module - no external
provider or real infrastructure involved.

(A different example, [`02-ephemeral-resources/01-valid-response`](../../02-ephemeral-resources/01-valid-response),
also has a child module, but for a different reason - working around the
restriction that root modules can't declare ephemeral outputs. This
example uses a child module to demonstrate module authoring/composition
as a first-class concept in its own right.)

## Files

- `modules/widget/main.tf` - a self-contained module: `variable "name"`,
  `variable "size"` (default `"medium"`), `resource "terraform_data" "widget"`,
  and outputs `id` and `summary`.
- `main.tf` - `variable "widgets"` (a map, two entries by default) and
  `module "widget"` with `for_each = var.widgets`, plus a root
  `output "widget_summaries"` reading `m.summary` from every module
  instance.

## How to test

```bash
terraform init
terraform plan
```

Expect two module instances, one per map key, and:

```
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + widget_summaries = {
      + large_blue = "large_blue (large)"
      + small_red  = "small_red (small)"
    }
```
