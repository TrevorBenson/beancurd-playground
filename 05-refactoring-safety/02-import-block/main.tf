terraform {
  required_version = ">= 1.5.0" # import blocks require Terraform/OpenTofu >= 1.5
}

# An `import` block declares "bring the object with this id under
# management as this resource address" as part of a normal plan, instead
# of running the separate `terraform import` CLI command. Uses the
# built-in terraform_data resource - no external provider or real
# infrastructure involved.
#
# terraform_data doesn't have any real backing store, so its "id" is just
# an opaque identifier assigned at creation - this example simulates a
# resource that already exists outside the current state (removed via
# `terraform state rm`, see the README) and re-adopts it by id via the
# import block below, without destroying/recreating it.

resource "terraform_data" "example" {
  input = "pre-existing-value"
}

import {
  to = terraform_data.example
  id = "REPLACE_WITH_REAL_ID_FROM_README_STEPS" # see README - this is a placeholder you must replace with a real id captured from your own run
}
