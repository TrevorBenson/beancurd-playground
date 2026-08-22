# Ephemeral variables: a real omission, not a display trick

Demonstrates that `ephemeral = true` genuinely removes a variable's value
from both the plan and state data - unlike `sensitive` (see
[`../01-sensitive-variable-plan-vs-state`](../01-sensitive-variable-plan-vs-state)),
which only hides it from CLI display while leaving the real value in both
files. Uses the built-in `terraform_data` resource - no external provider
or real infrastructure involved.

The commands below use `-var 'eph_token=...'` with a fake placeholder
value for a short, copy-pasteable walkthrough. If you adapt this to a
*real* secret, don't use `-var` on the command line - see [the tier
README's note on this](../README.md#a-note-on--var-in-these-walkthroughs)
for why (shell history, process list exposure) and what to use instead.

## Why `eph_token` has no `default`

A hardcoded `default = "some-real-secret"` in a *committed* `.tf` file
leaks that secret regardless of `sensitive` or `ephemeral` - the saved
plan file archives your entire config source (so it can `apply` later
without needing your `.tf` files again), and that archived source
literally contains the `default = "..."` line as text. This isn't a flaw
in the ephemeral mechanism - it's a property of the plan file format that
applies to *any* variable, sensitive/ephemeral or not. The lesson: never
put a real secret in a `default` value in committed code. This example
requires you to supply `eph_token` at plan time via `-var`, exactly the
way you'd supply a real one.

Prove this yourself: temporarily add `default = "test-hardcoded-secret"` to
`eph_token`, plan (`terraform plan -out=tfplan`), then:

```bash
mkdir -p /tmp/unz-eph-proof && unzip -o tfplan -d /tmp/unz-eph-proof
grep -rl "test-hardcoded-secret" /tmp/unz-eph-proof
```

Expect it to show up only in the archived config source
(`tfconfig/m-/main.tf`), never in the plan's actual data - proving the
leak is about config archival, not the ephemeral mechanism failing.
Revert the hardcoded default afterward and re-run `terraform plan -var
'eph_token=...'` to confirm the example is back to its clean, committed
state.

## Files

- `main.tf` - `variable "eph_token"` (`ephemeral = true`, no default),
  `variable "plain_note"`, `resource "terraform_data" "config"` using only
  the plain variable, a `local.eph_local` derived from the ephemeral
  variable, and a `check` block asserting on it (proving `check` is a
  sanctioned context for ephemeral values).

## How to test

```bash
terraform init
terraform plan -var 'eph_token=RUNTIME-ONLY-SECRET-abc123' -out=tfplan
```

Expect a clean plan (the `check` passes silently) with no mention of
`eph_token` anywhere in the "Changes to Outputs" section, since it isn't
in any output.

Now prove it's actually absent, not just hidden:

```bash
terraform show -json tfplan > plan.json
grep -c "RUNTIME-ONLY-SECRET" plan.json || echo "0 - confirmed absent from plan JSON"
```

Expect `0`. Compare this to
[`../01-sensitive-variable-plan-vs-state`](../01-sensitive-variable-plan-vs-state),
where the same `grep -c` against a *sensitive* value's plan JSON returned
`1` or more.

Now try to apply the saved plan **without** re-supplying the ephemeral
value:

```bash
terraform apply tfplan
```

Expect a specific, named error - proof the saved plan file genuinely holds
nothing for this variable and cannot recover it on its own:

```
Error: No value for required variable

  on main.tf line 13:
  13: variable "eph_token" {

Variable "eph_token" is configured as ephemeral. This type of variables
need to be given a value during `tofu plan` and also during `tofu apply`.
```

(Your tool may print `terraform` instead of `tofu` depending on which
binary you're running - the message is otherwise identical.)

Re-supply it to actually apply:

```bash
terraform apply -auto-approve -var 'eph_token=RUNTIME-ONLY-SECRET-abc123' tfplan
```

Then confirm the state file is equally clean:

```bash
terraform show -json terraform.tfstate > state.json
grep -c "RUNTIME-ONLY-SECRET" state.json || echo "0 - confirmed absent from state"
```

Expect `0`.

Clean up:

```bash
terraform destroy -auto-approve -var 'eph_token=RUNTIME-ONLY-SECRET-abc123'
rm -f tfplan plan.json state.json
```

Note: `destroy` also re-demands `eph_token`, for the same reason `apply`
did - the `check` block and `local.eph_local` both reference it, and
OpenTofu/Terraform evaluates the full configuration graph (including
`check` blocks) for `destroy` too, so the ephemeral variable is required
even though no resource in this example actually depends on it.
