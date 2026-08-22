# Combining plain, sensitive, and sensitive+ephemeral variables

Runs three variables - an ordinary one, a `sensitive`-only one, and a
`sensitive` **and** `ephemeral` one - through the same four allowed
contexts established in
[`../03-ephemeral-context-limits`](../03-ephemeral-context-limits):
provider configuration, an ephemeral resource's postcondition, a `check`
block, and an ordinary resource's `lifecycle precondition`. Requires real
network access to `jsonplaceholder.typicode.com` and Terraform/OpenTofu
>= 1.10.

## What each variable can and can't do

| | `plain` | `sensitive_only` | `sensitive_ephemeral` |
|---|---|---|---|
| Root-module output | ✅ (plain) | ✅ (must mark output `sensitive = true`) | ❌ - root modules can't have ephemeral outputs at all |
| Ordinary resource argument | ✅ | ✅ | ❌ - "ephemeral value used in non-ephemeral context" |
| Provider config / ephemeral resource / check / precondition | ✅ | ✅ | ✅ |
| Present in plan/state JSON | ✅ plaintext | ✅ plaintext (with a `sensitive` marker) | ❌ absent entirely |

## The warning-message matrix

If an `error_message` interpolates the raw value directly (rather than
just gating on a boolean `condition`, as this example's shipped `main.tf`
does), OpenTofu suppresses the message and warns instead of showing it -
and the *wording* of that warning depends on exactly which marking is
present. Try each of these yourself by temporarily editing the `se_check`
block's `error_message`:

**1. Interpolate `local.se_local` directly:**
```hcl
error_message = "sensitive_ephemeral must be longer than 3 chars: got '${local.se_local}'"
```
```
Warning: Error message refers to sensitive values

The error expression used to explain this condition refers to sensitive
values, so OpenTofu will not display the resulting message.

You can correct this by removing references to sensitive values, or by
carefully using the nonsensitive() function if the expression will not
reveal the sensitive data.
```
Notice it says **sensitive**, not ephemeral - even though this value is
both. The sensitive check is reported first.

**2. Wrap it in `nonsensitive()` only:**
```hcl
error_message = "sensitive_ephemeral must be longer than 3 chars: got '${nonsensitive(local.se_local)}'"
```
```
Warning: Error message refers to ephemeral values

The error expression used to explain this condition refers to ephemeral
values, so OpenTofu will not display the resulting message.

You can correct this by removing references to ephemeral values or by
utilizing the builtin ephemeralasnull() function.
```
The warning **flips to the ephemeral wording** - proving `sensitive` and
`ephemeral` are two *independent* gates, not one shadowing the other.
Stripping the sensitive gate reveals the ephemeral gate underneath.

**3. Wrap it in both `nonsensitive()` and `ephemeralasnull()`:**
```hcl
error_message = "sensitive_ephemeral must be longer than 3 chars: got '${nonsensitive(ephemeralasnull(local.se_local))}'"
```
```
Error: Invalid template interpolation value

The expression result is null. Cannot include a null value in a string
template.
```
This is a hard **error**, not a warning - because `ephemeralasnull()`
doesn't reveal the real value the way `nonsensitive()` does; it destroys
it, substituting `null`. There is no ephemeral equivalent of
`nonsensitive()` that lets you actually see the value - by design.

After trying any of these, revert `se_check`'s `error_message` back to the
condition-only version shown in the shipped `main.tf`.

## Files

- `main.tf` - `variable "plain"`, `variable "sensitive_only"`, `variable
  "sensitive_ephemeral"`, and the four allowed-context uses of
  `sensitive_ephemeral` described above.

## How to test

```bash
terraform init
terraform plan -var 'sensitive_ephemeral=SE-VALUE-999'
```

Expect the ephemeral resource to open/close successfully, all
check/precondition/postcondition assertions to pass silently, and:

```
Changes to Outputs:
  + plain_out          = "plain-value"
  + sensitive_only_out = (sensitive value)

Plan: 1 to add, 0 to change, 0 to destroy.
```

Now prove `sensitive_only` is in the plan JSON but `sensitive_ephemeral`
is not (same technique as
[`../01-sensitive-variable-plan-vs-state`](../01-sensitive-variable-plan-vs-state)
and
[`../02-ephemeral-variable-basics`](../02-ephemeral-variable-basics)):

```bash
terraform plan -input=false -var 'sensitive_ephemeral=SE-VALUE-999' -out=tfplan
terraform show -json tfplan > plan.json
grep -c "sensitive-value" plan.json   # sensitive_only's default - expect 1+
grep -c "SE-VALUE-999" plan.json || echo "0 - sensitive_ephemeral confirmed absent"
```

Clean up:

```bash
terraform apply -auto-approve -var 'sensitive_ephemeral=SE-VALUE-999' tfplan
terraform destroy -auto-approve -var 'sensitive_ephemeral=SE-VALUE-999'
rm -f tfplan plan.json
```

Note: `sensitive_ephemeral` has no default, so `-var` is required on
`destroy` too, not just `plan`/`apply`.
