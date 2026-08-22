terraform {
  required_version = ">= 1.4.0"
}

# Marking a variable `sensitive = true` propagates that marking to anything
# derived from it - Terraform redacts it from plan/apply output and refuses
# to let it leak into a non-sensitive output without an explicit
# `sensitive = true` on that output too. Uses the built-in terraform_data
# resource - no external provider or real infrastructure involved.

variable "api_key" {
  description = "A secret value - never printed in plan/apply output or state diffs shown on screen."
  type        = string
  default     = "shhh-dont-print-me"
  sensitive   = true
}

resource "terraform_data" "config" {
  input = var.api_key
}

output "api_key_masked" {
  description = "Must be marked sensitive - terraform_data.config.output derives from a sensitive variable."
  value       = terraform_data.config.output
  sensitive   = true
}

output "non_sensitive_note" {
  description = "An ordinary output, shown normally, to contrast with the masked one above."
  value       = "config created"
}
