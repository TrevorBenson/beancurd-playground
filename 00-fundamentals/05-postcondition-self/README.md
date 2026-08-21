# Postcondition using `self`

Demonstrates a `lifecycle { postcondition {} }` block that uses `self` to
validate a resource's own just-computed result. `self` is only available in
`postcondition`, provisioner, and connection blocks - never in
`precondition`, since a precondition runs before the block's own result
exists. Uses the built-in `terraform_data` resource - no external provider
or real infrastructure involved.

## An important difference from `precondition`

A failed `precondition` (see
[`03-locals-precondition`](../03-locals-precondition)) stops the resource
from being created/updated at all. A failed **postcondition** runs *after*
the action - so on `apply`, the resource is already created (and written to
state) by the time the postcondition fails. Terraform still reports the
apply as an error, but the side effect already happened. This matters when
you're deciding whether a check belongs before or after the action it
guards.

## Files

- `main.tf` - `variable "input_value"` (default `-5`, deliberately
  negative), `resource "terraform_data" "doubled"` whose `input` is
  `var.input_value * 2`, with a `postcondition` asserting
  `self.output >= 0`.

## How to test

```bash
terraform init
terraform apply -auto-approve
```

With the default `input_value = -5`, `apply` **creates the resource, then
fails**:

```
terraform_data.doubled: Creating...
terraform_data.doubled: Creation complete after 0s [id=...]

Error: Resource postcondition failed
...
self.output is -10

Computed output (-10) must not be negative - got input_value=-5.
```

Run `terraform show` afterward and note `terraform_data.doubled` **is** in
state despite the error - that's the precondition/postcondition distinction
in action.

Now fix the input and re-apply:

```bash
terraform apply -auto-approve -var input_value=5
```

```
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

doubled = 10
```
