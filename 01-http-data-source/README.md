# `hashicorp/http` data source

Demonstrates the `hashicorp/http` provider's `data "http"` source: fetching
real data over HTTP at plan time, decoding it with `jsondecode()`, and
validating the result. Three self-contained sub-examples:

- [`01-fetch-and-decode-json`](01-fetch-and-decode-json) - a `data "http"`
  fetch against a known, fixed JSON endpoint, decoded and read with
  `jsondecode()`.
- [`02-precondition-validation`](02-precondition-validation) - extends
  `01-fetch-and-decode-json` with a `lifecycle { precondition {} }` that
  validates a variable against the *actual* fetched response.
- [`03-for-each-multiple-requests`](03-for-each-multiple-requests) - extends
  `01-fetch-and-decode-json` with `for_each` to fetch several fixed
  endpoints in a single apply.

Requires real network access to `jsonplaceholder.typicode.com`. See each
sub-directory's own README for exact test steps.
