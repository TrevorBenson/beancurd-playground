# Modules

Demonstrates authoring and consuming Terraform/OpenTofu modules - the
primary mechanism for packaging reusable configuration.

- [`01-authoring-and-consuming/`](01-authoring-and-consuming) - a minimal
  module with its own inputs/outputs, consumed from the root with
  `for_each` (one module instance per map entry).
