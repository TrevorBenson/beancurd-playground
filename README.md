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

## Learning path

Examples are grouped into tiers, roughly ordered from beginner to
intermediate. Within a tier, later examples build on earlier ones; later
tiers build on earlier tiers.

### Tier 0 - [`00-fundamentals`](00-fundamentals) (no external dependencies)

| Directory | Concept |
|-----------|---------|
| [`01-check-block-warning`](00-fundamentals/01-check-block-warning) | A `check` block assertion that warns during plan/apply without blocking it |
| [`02-key-exists-in-var-object`](00-fundamentals/02-key-exists-in-var-object) | Checking whether a key exists in an object-typed variable (`contains(keys())`, `can()`, `try()`) |
| [`03-locals-precondition`](00-fundamentals/03-locals-precondition) | Comparing two `local` values in a `lifecycle { precondition {} }`, hard-failing the plan on mismatch |
| [`04-variable-validation`](00-fundamentals/04-variable-validation) | A `variable` block's own `validation {}` rule, rejecting bad input before any plan begins |
| [`05-postcondition-self`](00-fundamentals/05-postcondition-self) | `lifecycle { postcondition {} }` using `self` to validate a resource's own computed result |
| [`06-for-each-multiple-resources`](00-fundamentals/06-for-each-multiple-resources) | `for_each` over a map to create multiple instances of the same resource |

### Tier 1 - [`01-http-data-source`](01-http-data-source) (requires network access)

| Directory | Concept |
|-----------|---------|
| [`01-fetch-and-decode-json`](01-http-data-source/01-fetch-and-decode-json) | `data "http"` fetching a known/fixed JSON response and accessing a key with `jsondecode()` |
| [`02-precondition-validation`](01-http-data-source/02-precondition-validation) | Extends #1: variable validation against the live HTTP response via a precondition, invalidating the plan |
| [`03-for-each-multiple-requests`](01-http-data-source/03-for-each-multiple-requests) | `for_each` over `data "http"` to fetch several known endpoints in one plan |

### Tier 2 - [`02-ephemeral-resources`](02-ephemeral-resources) (requires network access, Terraform/OpenTofu >= 1.10)

| Directory | Concept |
|-----------|---------|
| [`01-valid-response`](02-ephemeral-resources/01-valid-response) | `magodo/restful` `ephemeral "restful_resource"` - valid response + key access |
| [`02-invalid-response`](02-ephemeral-resources/02-invalid-response) | Same provider against a `401`/`404` response, showing a hard plan-time error |
| [`03-precondition-validation`](02-ephemeral-resources/03-precondition-validation) | Extends #1: variable validation against the ephemeral response via a precondition, invalidating the plan |

### Tier 3 - [`03-combined-chain`](03-combined-chain) (requires network access, Terraform/OpenTofu >= 1.10)

| Directory | Concept |
|-----------|---------|
| [`01-full-pipeline`](03-combined-chain/01-full-pipeline) | A single capstone example chaining variable validation, a `check` warning, a `data "http"` fetch + precondition, and an ephemeral resource fetch + postcondition |

## Conventions

- Every example has a `README.md` stating exactly what to run
  (`terraform validate` / `plan` / `apply`) and what you should observe.
- `.terraform.lock.hcl` files are committed for reproducibility;
  `.terraform/` directories and state files are gitignored.
- Examples needing real network access say so explicitly in their README
  and use stable, well-known public test endpoints
  (`jsonplaceholder.typicode.com`, `postman-echo.com`).
