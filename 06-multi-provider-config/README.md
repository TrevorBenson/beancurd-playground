# Multi-provider configuration

Demonstrates configuring a single provider more than once (via `alias`) to
talk to more than one distinct endpoint/account/region in the same
configuration.

- [`01-provider-aliases/`](01-provider-aliases) - the same `magodo/restful`
  provider configured twice, pointed at two different real endpoints, with
  each resource pinned to a specific configuration via `provider = restful.<alias>`.
