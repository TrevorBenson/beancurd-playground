# Sensitive variables: what plan/state actually contain

Demonstrates that `sensitive = true` is a **display-only** redaction - the
real plaintext value is present, unredacted, in the actual plan and state
data. Only the human-facing CLI text (`terraform plan`/`apply` console
output, `terraform output`'s default view) hides it. Uses the built-in
`terraform_data` resource - no external provider or real infrastructure
involved.

## What you'll prove

1. The CLI redacts `api_key_out` as `(sensitive value)` / `<sensitive>`.
2. `terraform show -json` on the **saved plan file** contains the real
   value anyway, right next to a `"sensitive"`/`"after_sensitive"` marker.
3. `terraform show -json` on the **state file** contains the real value
   too, the same way.
4. The raw *binary* plan file (a zip archive around a compressed protobuf
   payload) doesn't grep-match the value in either case - that's an
   artifact of binary encoding, not evidence of redaction. `terraform show
   -json` is the correct tool to inspect plan/state content; raw `grep` on
   the binary file proves nothing either way.

## Files

- `main.tf` - `variable "api_key"` (`sensitive = true`, default a fake
  secret string), `resource "terraform_data" "config"` using it, `output
  "api_key_out"` (`sensitive = true`), and `output "plain_note_out"` for
  contrast.

## How to test

```bash
terraform init
terraform plan -out=tfplan
```

Expect the CLI to redact it:

```
Changes to Outputs:
  + api_key_out    = (sensitive value)
  + plain_note_out = "not-secret-value"
```

Now inspect the *actual* plan content, not the CLI text:

```bash
terraform show -json tfplan > plan.json
grep -c "SUPER-SECRET-VALUE-12345" plan.json
```

Expect `1` (or more) - the real value is there. Look at the surrounding
JSON to see the marker sitting right next to it:

```bash
python3 -m json.tool plan.json | grep -A4 '"input":' | head -5
```

```
"input": "SUPER-SECRET-VALUE-12345",
"triggers_replace": null
},
"sensitive_values": {
    "input": true
```

(`"input"` appears more than once in the JSON - in the resource's
`values`, in `resource_changes.change.after`/`after_sensitive`, and in the
plan's `configuration` block - so a plain `grep -A2` would print several
`--`-separated matches. The `head -5` above just isolates the first,
clearest one for illustration; `grep -c` above is the count that actually
matters.)

Apply, then check the state file the same way:

```bash
terraform apply -auto-approve tfplan
terraform show -json terraform.tfstate > state.json
grep -c "SUPER-SECRET-VALUE-12345" state.json
```

Expect `1` (or more) again. Look at the state's own `outputs` block:

```bash
python3 -m json.tool state.json | grep -B1 -A2 '"api_key_out"'
```

```
"outputs": {
    "api_key_out": {
        "sensitive": true,
        "value": "SUPER-SECRET-VALUE-12345",
```

Now confirm the raw binary plan file proves nothing about redaction either
way (it's just a zip container around a compressed protobuf payload, so
raw `grep` fails to find *any* string, sensitive or not):

```bash
file tfplan
grep -a "SUPER-SECRET-VALUE-12345" tfplan || echo "not found raw (binary encoding, not redaction)"
grep -a "not-secret-value" tfplan || echo "not found raw either - proves grep-on-binary is meaningless here"
```

Both `grep`s should report "not found" - proving the earlier `terraform
show -json` result (which DID find the sensitive value) is the meaningful
test, not raw binary inspection.

Clean up:

```bash
terraform destroy -auto-approve
```

**The takeaway:** `sensitive = true` protects against *accidental display*
(a screen share, a CI log, a copy-pasted terminal). It does **not**
encrypt or omit the value from the plan/state data itself. Anyone with
read access to your state file or a saved plan file can read every
`sensitive` value in plain text. For a mechanism that actually keeps a
value out of both files, see
[`../02-ephemeral-variable-basics`](../02-ephemeral-variable-basics).
