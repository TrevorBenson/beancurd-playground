# Dynamic blocks

Demonstrates the `dynamic` block: generating a variable number of nested
*configuration blocks* (not resource instances - that's `for_each`/`count`,
covered in [`06-for-each-multiple-resources`](../06-for-each-multiple-resources)
and [`07-count-and-splat`](../07-count-and-splat)). `dynamic` only works
where the target block type is a genuinely repeatable nested block in a
provider's schema.

## Why `hashicorp/tls` instead of a provider-free resource

No provider-free or built-in resource in this repo's toolkit
(`terraform_data`) has a repeatable nested block to generate - the concept
requires a real resource schema that defines one. `hashicorp/tls` was
chosen because it computes everything locally (a private key and a
self-signed certificate, both pure cryptographic computation) with **no
network calls and no real cloud infrastructure**, while still having a
genuine repeatable nested block (`tls_self_signed_cert`'s `subject`) to
demonstrate the mechanism honestly.

## What this demonstrates

`dynamic "subject"` iterates `var.include_subject ? [var.subject_common_name] : []`
- a list with either one element or zero. This is the classic "optional
nested block" pattern: when the list is empty, zero `subject` blocks are
emitted; when it has one element, exactly one is. The same pattern
generalizes to any list/map with more than one element, emitting one block
per entry.

A **`dynamic` block cannot be used for `provisioner`, `connection`, or
`lifecycle` blocks** - only for a resource, data source, or provider's own
schema-defined nested block types. (This repo's earlier examples all use
`lifecycle { precondition/postcondition {} }`, which is exactly the kind of
block `dynamic` does *not* apply to.)

## Files

- `main.tf` - `variable "include_subject"` (default `true`) and
  `variable "subject_common_name"`, `resource "tls_private_key" "example"`,
  and `resource "tls_self_signed_cert" "example"` with a
  `dynamic "subject"` block.

## How to test

```bash
terraform init
terraform apply -auto-approve
```

With the default `include_subject = true`, expect:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

cert_has_subject = true
```

Now flip it off:

```bash
terraform apply -auto-approve -var include_subject=false
```

```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

cert_has_subject = false
```

(The certificate is recreated because `validity_period_hours`/`allowed_uses`
depend on the private key relationship, not because of the dynamic block
itself - only `tls_self_signed_cert` changes, `tls_private_key` doesn't.)

Clean up:

```bash
terraform destroy -auto-approve
```
