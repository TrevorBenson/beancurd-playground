# beancurd-playground

Self-contained Terraform/OpenTofu examples used as reference material for
combining into real plans. Each directory is a standalone proof of concept:
its own `main.tf`, its own `README.md` explaining exactly how to exercise
it, and no dependency on any other example. Providers with external/network
dependencies are only used where the concept genuinely requires them
(fetching and parsing a real HTTP response); everything else uses
provider-free language features or the built-in `terraform_data` resource.

Tested with OpenTofu v1.11.5 (the `terraform` binary in this environment is
an OpenTofu build); the language features used are standard Terraform
1.5-1.10+ features and should behave identically on HashiCorp Terraform of
matching or later versions.

## Examples

| # | Directory | Concept |
|---|-----------|---------|
| 1 | [`01-plan-check-warning`](01-plan-check-warning) | A `check` block assertion that warns during plan/apply without blocking it |
| 2 | [`02-key-exists-in-var-object`](02-key-exists-in-var-object) | Checking whether a key exists in an object-typed variable (`contains(keys())`, `can()`, `try()`) |
| 3 | [`03-locals-comparison-precondition`](03-locals-comparison-precondition) | Comparing two `local` values in a `lifecycle { precondition {} }`, hard-failing the plan on mismatch |
| 4 | [`04-data-http-json-key`](04-data-http-json-key) | `data "http"` fetching a known/fixed JSON response and accessing a key with `jsondecode()` |
| 5 | [`05-restful-ephemeral-resource`](05-restful-ephemeral-resource) | `magodo/restful` `ephemeral "restful_resource"` - [valid response + key access](05-restful-ephemeral-resource/valid-response) and [invalid response (401/404)](05-restful-ephemeral-resource/invalid-response) |
| 6 | [`06-http-precondition-validation`](06-http-precondition-validation) | Extends #4: variable validation against the live HTTP response via a precondition, invalidating the plan |
| 7 | [`07-ephemeral-precondition-validation`](07-ephemeral-precondition-validation) | Extends #5: variable validation against the ephemeral response via a precondition, invalidating the plan |

## Conventions

- Every example has a `README.md` stating exactly what to run
  (`terraform validate` / `plan` / `apply`) and what you should observe.
- `.terraform.lock.hcl` files are committed for reproducibility;
  `.terraform/` directories and state files are gitignored.
- Examples needing real network access say so explicitly in their README
  and use stable, well-known public test endpoints
  (`jsonplaceholder.typicode.com`, `postman-echo.com`).
