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
