terraform {
  required_version = ">= 1.5.0"
}

# A variable's own `validation` block rejects bad input before Terraform
# even starts building a plan - contrast with 03-locals-precondition, where
# the failure only surfaces once a resource/data/output is evaluated, and
# with 01-check-block-warning, where a failure only ever warns.

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, production."
  }
}

output "environment" {
  value = var.environment
}
