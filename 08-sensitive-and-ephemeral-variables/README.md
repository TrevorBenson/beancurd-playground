# Sensitive and ephemeral variables

A rigorous, verified tour of `sensitive` and `ephemeral` variables in
Terraform/OpenTofu >= 1.10: what each marking actually does to the plan
and state files (not what you'd assume), where ephemeral values can and
can't be used, the write-only-argument escape hatch for feeding them into
real managed resources, and a capstone showing the flagship real-world use
case - fetching a secret from HashiCorp Vault that never touches state.

- [`01-sensitive-variable-plan-vs-state/`](01-sensitive-variable-plan-vs-state) -
  `sensitive = true` is a display-only redaction; the real value is
  plaintext in both the plan JSON and the state file.
- [`02-ephemeral-variable-basics/`](02-ephemeral-variable-basics) -
  `ephemeral = true` is a real omission from both files, verified absent
  via `terraform show -json`.
- [`03-ephemeral-context-limits/`](03-ephemeral-context-limits) - the
  contexts an ephemeral value is accepted in and rejected from that this
  tier demonstrates (not an exhaustive catalog), with the exact error
  text for every rejected case.
- [`04-write-only-arguments-reference/`](04-write-only-arguments-reference) -
  schema-only reference (no live AWS): the sanctioned way a real managed
  resource can accept an ephemeral value.
- [`05-combining-plain-sensitive-and-sensitive-ephemeral/`](05-combining-plain-sensitive-and-sensitive-ephemeral) -
  a plain, a sensitive-only, and a sensitive+ephemeral variable run
  through every allowed context, plus the warning-message matrix proving
  the two markings are independent, stacked gates.
- [`06-vault-dynamic-secrets/`](06-vault-dynamic-secrets) - a real local
  HashiCorp Vault dev server, fetched via an ephemeral resource
  authenticated with a sensitive+ephemeral token; also documents (without
  live-testing) Vault's wider ephemeral-resource roster and its
  Kerberos/OIDC/etc. provider auth blocks.

Requires Terraform/OpenTofu >= 1.10 throughout (>= 1.5 for
`01-sensitive-variable-plan-vs-state` alone, which predates ephemeral
variables; >= 1.11 for `04-write-only-arguments-reference` alone, which
documents a write-only-argument protocol feature that shipped in 1.11).
`03`, `05`, and `06` require real network access; `06` additionally
requires a locally-running Vault dev server (see its own README) and
`04` downloads a large provider binary purely to read its schema.

## A note on `-var` in these walkthroughs

Every example uses `-var 'name=value'` on the command line to keep the
walkthrough commands short and copy-pasteable, and that's fine with the
fake placeholder values shown - but `-var` puts the value in your shell
history and briefly makes it visible to other local users via the process
list (e.g. `ps aux`) while the command runs. If you adapt any of these
examples to a *real* secret, prefer a `TF_VAR_<name>` environment variable
(e.g. `export TF_VAR_eph_token=...` before running `terraform plan`, or
`TF_VAR_eph_token=... terraform plan` for a single command) or an
interactive prompt instead - both keep the value out of shell history and
the visible command line. This applies equally to ordinary `sensitive`
variables and to `ephemeral` ones; `ephemeral` only protects the value
once it reaches Terraform/OpenTofu, not on the way in.
