# Fundamentals

Core Terraform/OpenTofu language building blocks used throughout the rest of
this repo - `check` blocks, variable validation, lifecycle pre/postconditions,
and `for_each` - demonstrated in isolation with no provider or real
infrastructure required.

- [`01-check-block-warning`](01-check-block-warning) - a `check` block
  assertion that only ever warns, never blocks the plan.
- [`02-key-exists-in-var-object`](02-key-exists-in-var-object) - three common
  patterns for safely checking whether a key exists in an object-typed
  variable.
- [`03-locals-precondition`](03-locals-precondition) - a `lifecycle
  { precondition {} }` block that compares two `local` values and hard-fails
  the plan when they disagree.
- [`04-variable-validation`](04-variable-validation) - a `variable` block's own
  `validation {}` rule, rejecting bad input before anything else is evaluated.
- [`05-postcondition-self`](05-postcondition-self) - a `lifecycle
  { postcondition {} }` block using `self` to validate a resource's own
  just-computed result.
- [`06-for-each-multiple-resources`](06-for-each-multiple-resources) - the
  `for_each` meta-argument creating one resource instance per map entry.
- [`07-count-and-splat`](07-count-and-splat) - the `count` meta-argument and
  `[*]` splat expressions, contrasted with `for_each`.
- [`08-sensitive-values`](08-sensitive-values) - `sensitive = true` on
  variables and outputs, and how the marking propagates.
- [`09-string-and-collection-functions`](09-string-and-collection-functions) -
  `join()`, `merge()`, `lookup()`, a for-expression, and `templatefile()`.
- [`10-depends-on`](10-depends-on) - forcing an explicit creation order
  between two resources with no attribute reference between them.
- [`11-dynamic-blocks`](11-dynamic-blocks) - generating a variable number of
  nested configuration blocks (using `hashicorp/tls` for a resource that
  actually has one).
