# String and collection functions, and `templatefile()`

A tour of everyday HCL functions beyond `jsondecode()`/`contains()`/`try()`/
`can()` (already covered in
[`01-fetch-and-decode-json`](../../01-http-data-source/01-fetch-and-decode-json)
and [`02-key-exists-in-var-object`](../02-key-exists-in-var-object)):
`join()`, a for-expression, `merge()`, `lookup()`, and `templatefile()`. No
provider or real infrastructure is used.

## Files

- `greeting.tftpl` - a one-line template with `${name}` and `${count}`
  placeholders.
- `main.tf` - `variable "user_config"` (a map, default 2 entries) and a
  `locals` block computing:
  - `summary` - `join(", ", [for k, v in var.user_config : "${k}=${v}"])`
  - `merged` - `merge(var.user_config, { extra = "yes" })`
  - `greeting` - `templatefile("${path.module}/greeting.tftpl", { ... })`
    using `lookup(var.user_config, "name", "stranger")` for a safe default.

## How to test

```bash
terraform init
terraform plan
```

Expect:

```
Changes to Outputs:
  + greeting = <<-EOT
        Hello, Ada! You have 3 new message(s).
    EOT
  + merged   = {
      + extra = "yes"
      + name  = "Ada"
      + role  = "admin"
    }
  + summary  = "name=Ada, role=admin"
```

Try overriding `user_config` without a `name` key, e.g.
`terraform plan -var 'user_config={"role"="viewer"}'`, and note `greeting`
falls back to `"Hello, stranger!..."` via `lookup()`'s default instead of
erroring.
