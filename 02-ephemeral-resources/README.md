# `magodo/restful` ephemeral resources

Demonstrates the `magodo/restful` provider's `ephemeral "restful_resource"`
block: a REST call whose result is never written to state and is re-fetched
on every plan/apply. Three self-contained sub-examples:

- [`01-valid-response/`](01-valid-response) - a successful GET against a known,
  fixed JSON endpoint, accessing a key from the response.
- [`02-invalid-response/`](02-invalid-response) - the same idea against an
  endpoint returning `401`/`404`, showing how the provider surfaces a
  non-2xx response as a hard plan-time error.
- [`03-precondition-validation/`](03-precondition-validation) - extends
  `01-valid-response`: variable validation against the ephemeral response
  via a `lifecycle` precondition, invalidating the plan when it doesn't
  match.

Requires Terraform or OpenTofu **>= 1.10** (ephemeral resources) and real
network access. See each sub-directory's own README for exact test steps.
