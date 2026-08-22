# Refactoring safety

Demonstrates the two mechanisms Terraform/OpenTofu provide for changing
configuration without Terraform mistaking a refactor for a real
infrastructure change: `moved` blocks (renaming a resource/module) and
`import` blocks (adopting an already-existing object into state).

- [`01-moved-block/`](01-moved-block) - renaming a resource without a
  destroy-then-create.
- [`02-import-block/`](02-import-block) - bringing an existing object under
  Terraform management via a declarative `import` block instead of the
  `terraform import` CLI command.
