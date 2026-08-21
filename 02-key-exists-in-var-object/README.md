# Checking whether a key exists in a var object

Demonstrates the three common patterns for safely checking whether an
arbitrary key is present in an object-typed variable, without erroring when
it's missing. No provider or real infrastructure is used.

## Files

- `main.tf` - `variable "config"` (an `any`-typed object) and
  `variable "required_key"`, plus locals/outputs showing:
  - `contains(keys(var.config), required_key)`
  - `can(var.config[required_key])`
  - `try(var.config[required_key], "KEY_NOT_FOUND")` to get the value *or* a
    fallback in one step

## How to test

```bash
terraform init
terraform plan
```

With the default `config = { name = "example", region = "us-east-1" }` and
`required_key = "region"`, expect:

```
key_exists_via_can      = true
key_exists_via_contains = true
value_or_default        = "us-east-1"
```

Now point at a key that isn't there:

```bash
terraform plan -var required_key=missing_key
```

Expect:

```
key_exists_via_can      = false
key_exists_via_contains = false
value_or_default        = "KEY_NOT_FOUND"
```

Note nothing errors in either case - that's the point of this pattern.
