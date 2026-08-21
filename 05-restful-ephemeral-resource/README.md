# `magodo/restful` ephemeral resources

Demonstrates the `magodo/restful` provider's `ephemeral "restful_resource"`
block: a REST call whose result is never written to state and is re-fetched
on every plan/apply. Two self-contained sub-examples:

- [`valid-response/`](valid-response) - a successful GET against a known,
  fixed JSON endpoint, accessing a key from the response.
- [`invalid-response/`](invalid-response) - the same idea against an
  endpoint returning `401`/`404`, showing how the provider surfaces a
  non-2xx response as a hard plan-time error.

Requires Terraform or OpenTofu **>= 1.10** (ephemeral resources) and real
network access. See each sub-directory's own README for exact test steps.
