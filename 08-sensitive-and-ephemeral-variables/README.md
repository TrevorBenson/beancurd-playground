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
- [`03-ephemeral-context-limits/`](03-ephemeral-context-limits) - the full
  allow-list of contexts an ephemeral value can be used in, and the exact
  error text for the contexts it's rejected from.
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
variables). `03`, `05`, and `06` require real network access;
`06` additionally requires a locally-running Vault dev server (see its
own README) and `04` downloads a large provider binary purely to read its
schema.
