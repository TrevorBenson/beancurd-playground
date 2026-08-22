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
| [`07-count-and-splat`](00-fundamentals/07-count-and-splat) | The `count` meta-argument and `[*]` splat expressions, contrasted with `for_each` |
| [`08-sensitive-values`](00-fundamentals/08-sensitive-values) | `sensitive = true` on variables and outputs, and how the marking propagates |
| [`09-string-and-collection-functions`](00-fundamentals/09-string-and-collection-functions) | `join()`, `merge()`, `lookup()`, a for-expression, and `templatefile()` |
| [`10-depends-on`](00-fundamentals/10-depends-on) | Forcing an explicit creation order between two resources with no attribute reference between them |
| [`11-dynamic-blocks`](00-fundamentals/11-dynamic-blocks) | Generating a variable number of nested configuration blocks (`hashicorp/tls`, local-only computation) |

### Tier 1 - [`01-http-data-source`](01-http-data-source) (requires network access)

| Directory | Concept |
|-----------|---------|
| [`01-fetch-and-decode-json`](01-http-data-source/01-fetch-and-decode-json) | `data "http"` fetching a known/fixed JSON response and accessing a key with `jsondecode()` |
| [`02-precondition-validation`](01-http-data-source/02-precondition-validation) | Extends `01-fetch-and-decode-json`: variable validation against the live HTTP response via a precondition, invalidating the plan |
| [`03-for-each-multiple-requests`](01-http-data-source/03-for-each-multiple-requests) | `for_each` over `data "http"` to fetch several known endpoints in one plan |

### Tier 2 - [`02-ephemeral-resources`](02-ephemeral-resources) (requires network access, Terraform/OpenTofu >= 1.10)

| Directory | Concept |
|-----------|---------|
| [`01-valid-response`](02-ephemeral-resources/01-valid-response) | `magodo/restful` `ephemeral "restful_resource"` - valid response + key access |
| [`02-invalid-response`](02-ephemeral-resources/02-invalid-response) | Same provider against a `401`/`404` response, showing a hard plan-time error |
| [`03-precondition-validation`](02-ephemeral-resources/03-precondition-validation) | Extends `01-valid-response`: variable validation against the ephemeral response via a precondition, invalidating the plan |

### Tier 3 - [`03-combined-chain`](03-combined-chain) (requires network access, Terraform/OpenTofu >= 1.10)

| Directory | Concept |
|-----------|---------|
| [`01-full-pipeline`](03-combined-chain/01-full-pipeline) | A single capstone example chaining variable validation, a `check` warning, a `data "http"` fetch + precondition, and an ephemeral resource fetch + postcondition |

### Tier 4 - [`04-modules`](04-modules) (no external dependencies)

| Directory | Concept |
|-----------|---------|
| [`01-authoring-and-consuming`](04-modules/01-authoring-and-consuming) | A minimal reusable module with its own inputs/outputs, consumed from the root with `for_each` |

### Tier 5 - [`05-refactoring-safety`](05-refactoring-safety) (no external dependencies)

| Directory | Concept |
|-----------|---------|
| [`01-moved-block`](05-refactoring-safety/01-moved-block) | Renaming a resource without a destroy-then-create, via a `moved` block |
| [`02-import-block`](05-refactoring-safety/02-import-block) | Adopting an existing object into state via a declarative `import` block |

### Tier 6 - [`06-multi-provider-config`](06-multi-provider-config) (requires network access, Terraform/OpenTofu >= 1.10)

| Directory | Concept |
|-----------|---------|
| [`01-provider-aliases`](06-multi-provider-config/01-provider-aliases) | The same provider configured twice with different aliases, each resource pinned to one via `provider = type.alias` |

### Tier 7 - [`07-testing`](07-testing) (no external dependencies)

| Directory | Concept |
|-----------|---------|
| [`01-terraform-test-framework`](07-testing/01-terraform-test-framework) | `.tftest.hcl` `run` blocks and `expect_failures`, distinct from plan/apply-time checks |

## Conventions

- Every example has a `README.md` stating exactly what to run
  (`terraform validate` / `plan` / `apply`) and what you should observe.
- `.terraform.lock.hcl` files are committed for reproducibility;
  `.terraform/` directories and state files are gitignored.
- Examples needing real network access say so explicitly in their README
  and use stable, well-known public test endpoints
  (`jsonplaceholder.typicode.com`, `postman-echo.com`).
