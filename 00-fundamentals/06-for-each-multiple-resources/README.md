# `for_each` over a map to create multiple resources

Demonstrates the `for_each` meta-argument: one resource instance is created
per entry in `var.widgets`, addressed as `terraform_data.widget["small_red"]`
/ `terraform_data.widget["large_blue"]` rather than by numeric index. Uses
the built-in `terraform_data` resource - no external provider or real
infrastructure involved.

## Files

- `main.tf` - `variable "widgets"` (a `map(object({size, color}))`, two
  entries by default) and `resource "terraform_data" "widget"` with
  `for_each = var.widgets`, referencing `each.key` / `each.value` in its
  `input`.

## How to test

```bash
terraform init
terraform plan
```

Expect two separate resource instances in the plan, one per map key:

```
  # terraform_data.widget["large_blue"] will be created
  + resource "terraform_data" "widget" {
      + input  = {
          + color = "blue"
          + name  = "large_blue"
          + size  = "large"
        }
      ...
    }

  # terraform_data.widget["small_red"] will be created
  + resource "terraform_data" "widget" {
      + input  = {
          + color = "red"
          + name  = "small_red"
          + size  = "small"
        }
      ...
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

Try adding or removing an entry from `var.widgets` (e.g. via a
`-var 'widgets={...}'` override or by editing the default) and re-plan -
only the changed keys show as added/destroyed; unrelated keys are
untouched. This is the core benefit of `for_each` over `count`: reordering
or removing one entry doesn't churn every other instance.
```
