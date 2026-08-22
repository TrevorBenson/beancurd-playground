# `import` blocks: adopting an existing object into state

Demonstrates the `import` block: declaratively bringing an
already-existing object under Terraform management as part of a normal
`terraform plan`/`apply`, instead of running the separate `terraform
import <address> <id>` CLI command. Uses the built-in `terraform_data`
resource - no external provider or real infrastructure involved.

## Why the id in `main.tf` is a placeholder

`terraform_data` doesn't have any real backing store or a predictable id
format - a real id is only assigned when one is created. This example
simulates "a resource that already exists but Terraform doesn't know about
it yet" by creating one normally, capturing its real id, deliberately
forgetting about it (`terraform state rm`), and then re-adopting it via
an `import` block using the id you just captured. **You must substitute
your own captured id** for the placeholder in `main.tf` - a real id from
a real provider (an AWS instance ID, a GCP resource URL, etc.) is exactly
what you'd put there in a non-simulated case.

## How to test

```bash
terraform init
```

Simulate a pre-existing, unmanaged object and capture its real id:

```bash
cp main.tf main.tf.bak
cat > main.tf <<'EOF'
resource "terraform_data" "example" {
  input = "pre-existing-value"
}
EOF
terraform apply -auto-approve
REAL_ID=$(terraform state show terraform_data.example | grep -oP '(?<=id\s{5}= ")[^"]+')
echo "captured id: $REAL_ID"
terraform state rm terraform_data.example   # forget it, simulating "not yet under management"
cp main.tf.bak main.tf                      # restore this example's real main.tf (with the import block)
```

Now edit `main.tf` and replace the placeholder id
(`REPLACE_WITH_REAL_ID_FROM_README_STEPS`) with the `$REAL_ID` you just
captured, then plan:

```bash
terraform plan
```

Expect OpenTofu to plan importing the existing object rather than
creating a brand new one:

```
  # terraform_data.example will be updated in-place
  # (imported from "<your-real-id>")
  ~ resource "terraform_data" "example" {
        id     = "<your-real-id>"
      + input  = "pre-existing-value"
      + output = (known after apply)
    }

Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.
```

(The `1 to change` here is a `terraform_data` quirk - the CLI-simulated
"existing" object doesn't retain its `input` value across the `state rm`
in this simulation, so re-adopting it also sets `input` for the first
time. A real provider resource with actual persisted attributes would
typically show `0 to change` once its full state is read back during
import.)

Clean up:

```bash
terraform destroy -auto-approve
```
