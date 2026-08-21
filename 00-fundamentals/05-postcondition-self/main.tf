terraform {
  required_version = ">= 1.4.0"
}

# `self` (referring to a block's own result) is only valid in
# postcondition/provisioner/connection blocks, never in `precondition` -
# see 01-http-data-source/02-precondition-validation and
# 02-ephemeral-resources/03-precondition-validation for what happens if you
# try it in a precondition instead. This example shows the case `self`
# actually works for: validating a resource's own freshly-computed result.
#
# Uses the built-in terraform_data resource - no external provider needed.

variable "input_value" {
  description = "A number this (fictional) config doubles."
  type        = number
  default     = -5 # intentionally produces a negative result
}

resource "terraform_data" "doubled" {
  input = var.input_value * 2

  lifecycle {
    postcondition {
      condition     = self.output >= 0
      error_message = "Computed output (${self.output}) must not be negative - got input_value=${var.input_value}."
    }
  }
}

output "doubled" {
  value = terraform_data.doubled.output
}
