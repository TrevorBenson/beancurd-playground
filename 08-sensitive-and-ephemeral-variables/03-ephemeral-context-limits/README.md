# Where ephemeral values can (and can't) be used

A complete tour of the contexts an `ephemeral` value is accepted in, and
the ones it's rejected from - with the exact, real error text for every
rejected case, captured from actual `terraform validate` runs rather than
guessed. Requires real network access to `jsonplaceholder.typicode.com`
and Terraform/OpenTofu >= 1.10.

## Allowed contexts

This list covers every context *demonstrated by this tier* - it is not an
exhaustive catalog of every ephemeral-safe context Terraform/OpenTofu
supports. Contexts 1-6 are shown directly in this directory's `main.tf`;
7 and 8 are demonstrated below instead, since they need a resource type or
module structure this shared `main.tf` doesn't otherwise use.

1. **Provider configuration arguments** - `provider "restful" { header = { Authorization = "Bearer ${var.eph_header_value}" } }`.
2. **Another ephemeral resource's arguments and lifecycle blocks** - `ephemeral "restful_resource" "todo"`, including its own `postcondition`.
3. **`check` block condition expressions** - only the pass/fail *status* is ever persisted to state, never the value used to compute it.
4. **`lifecycle precondition`/`postcondition` on an ordinary resource** - as long as the resource's own *arguments* don't reference the ephemeral value, only the condition does.
5. **Locals derived from an ephemeral value** (`local.eph_local = var.eph_token` in [`../02-ephemeral-variable-basics`](../02-ephemeral-variable-basics)) - the local itself becomes ephemeral and inherits all these same rules.
6. **Write-only (`_wo`) resource arguments** - not demonstrated here since no zero-dependency provider in this repo has adopted them; see [`../04-write-only-arguments-reference`](../04-write-only-arguments-reference).
7. **Provisioner configuration arguments.** A `provisioner` block's own arguments can reference an ephemeral value:
   ```hcl
   resource "terraform_data" "config" {
     input = "static-value"

     provisioner "local-exec" {
       command = "echo ${var.eph_header_value}"
     }
   }
   ```
   `terraform validate` and `terraform apply` both succeed - and the CLI
   even redacts the provisioner's own console output as a courtesy:
   ```
   terraform_data.config: Provisioning with 'local-exec'...
   terraform_data.config (local-exec): (output suppressed due to ephemeral value in config)
   ```
8. **Inputs to a child module, when the module's own input variable is also declared `ephemeral = true`:**
   ```hcl
   # modules/child/main.tf
   variable "eph_input" {
     type      = string
     ephemeral = true
   }
   ```
   ```hcl
   # root main.tf
   module "child" {
     source    = "./modules/child"
     eph_input = var.eph_header_value
   }
   ```
   This validates and plans cleanly - ephemerality is a property of the
   variable, and it propagates across the module boundary the same way it
   propagates into a `local`. If the child module's variable is **not**
   declared ephemeral, passing an ephemeral value to it is rejected:
   ```
   Error: Variable does not allow ephemeral value

     on main.tf line N, in module "child":
     N:   eph_input = var.eph_header_value

   The value used for the variable "eph_input" is ephemeral, but it is not
   configured to allow one.
   ```

## Disallowed contexts (try these yourself)

Each of these produces a plan-time error. Rather than ship broken code (every committed example in this repo must validate), reproduce each yourself:

**1. An ordinary resource's own argument.** Add this to a scratch copy of `main.tf`:
```hcl
resource "terraform_data" "broken" {
  input = var.eph_header_value
}
```
Run `terraform validate`. Expect:
```
Error: Ephemeral value used in non-ephemeral context

  with terraform_data.broken,
  on main.tf line N, in resource "terraform_data" "broken":
  N:   input = var.eph_header_value

Attribute ".input" is referencing an ephemeral value but ephemeral values
can be referenced only by other ephemeral attributes or by write-only ones.
```

**2. `for_each` or `count`.** Add:
```hcl
resource "terraform_data" "broken" {
  for_each = toset([var.eph_header_value])
  input    = each.key
}
```
Run `terraform validate`. Expect:
```
Error: Invalid for_each argument

  on main.tf line N, in resource "terraform_data" "broken":
  N:   for_each = toset([var.eph_header_value])
    ├────────────────
    │ var.eph_header_value has an ephemeral value

Ephemeral values, or values derived from ephemeral values, cannot be used
as for_each arguments. If used, the ephemeral value could be exposed as a
resource instance key.
```

**3. A data source's argument.** Add (needs the `hashicorp/http` provider declared too):
```hcl
data "http" "broken" {
  url = "https://jsonplaceholder.typicode.com/todos/${var.eph_header_value}"
}
```
Run `terraform validate`. Expect:
```
Error: Ephemeral value used in non-ephemeral context

  with data.http.broken,
  on main.tf line N, in data "http" "broken":
  N:   url = "https://jsonplaceholder.typicode.com/todos/${var.eph_header_value}"

Attribute ".url" is referencing an ephemeral value but ephemeral values can
be referenced only by other ephemeral attributes or by write-only ones.
```

**4. A root-module output.** Already demonstrated in
[`02-ephemeral-resources/01-valid-response`](../../02-ephemeral-resources/01-valid-response)
- root modules cannot declare `ephemeral = true` outputs at all, regardless
of what feeds them.

After trying any of these, delete the scratch addition and confirm
`terraform validate` on the unmodified `main.tf` passes again.

## Files

- `main.tf` - all four ALLOWED contexts, wired around one shared
  `var.eph_header_value`.

## How to test

```bash
terraform init
terraform plan -var 'eph_header_value=fake-ephemeral-bearer-token'
```

Expect the ephemeral resource to open/close successfully against the real
endpoint, and a clean plan:

```
ephemeral.restful_resource.todo: Opening...
ephemeral.restful_resource.todo: Open complete after 1s
ephemeral.restful_resource.todo: Closing...
ephemeral.restful_resource.todo: Close complete after 0s

Plan: 1 to add, 0 to change, 0 to destroy.
```
