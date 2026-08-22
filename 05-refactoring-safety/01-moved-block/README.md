# `moved` blocks: safely renaming a resource

Demonstrates a `moved` block: renaming a resource in configuration without
Terraform planning to destroy the old one and create a new one in its
place. Uses the built-in `terraform_data` resource - no external provider
or real infrastructure involved.

## The problem this solves

Terraform tracks resources in state by their configuration address
(`terraform_data.widget_new`). If you simply rename the resource block to
`terraform_data.widget_renamed`, Terraform sees a totally new address in
config and an orphaned one in state - its default behavior is to destroy
the orphaned one and create the new one, even though nothing about the
actual resource changed except its name in your `.tf` file. A `moved`
block tells Terraform explicitly "this is the same object, just renamed",
so it updates the address in state in place instead.

## Files

- `main.tf` - `resource "terraform_data" "widget_renamed"` plus a
  `moved { from = terraform_data.widget_new, to = terraform_data.widget_renamed }`
  block.

## How to test

This example ships already-renamed (with the `moved` block in place), so
to see the effect you first need state that still remembers the *old*
name. Simulate that:

```bash
terraform init
cat > /tmp/widget-new.tf <<'EOF'
resource "terraform_data" "widget_new" {
  input = "widget-a"
}
EOF
cp main.tf /tmp/main.tf.bak
cp /tmp/widget-new.tf main.tf
terraform apply -auto-approve   # creates terraform_data.widget_new in state
cp /tmp/main.tf.bak main.tf     # restore this example's real main.tf (the renamed version + moved block)
```

(If you abort partway through and `main.tf` ends up in an unexpected
state, `git checkout main.tf` restores the shipped version since it's
git-tracked.)

Now plan against the restored (renamed) configuration:

```bash
terraform plan
```

Expect OpenTofu to recognize the rename via the `moved` block - **no
destroy, no create**:

```
  # terraform_data.widget_new has moved to terraform_data.widget_renamed
    resource "terraform_data" "widget_renamed" {
        id     = "..."
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```

For contrast, try removing the `moved` block entirely and re-running
`terraform plan` against state that still has the old name - you'll see
`Plan: 1 to add, 0 to change, 1 to destroy.` instead, since OpenTofu now
has no way to know the two addresses refer to the same thing.

Clean up:

```bash
terraform destroy -auto-approve
```
