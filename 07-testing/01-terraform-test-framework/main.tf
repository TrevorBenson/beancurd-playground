terraform {
  required_version = ">= 1.6.0" # terraform test requires Terraform/OpenTofu >= 1.6
}

# The same variable-validation pattern from
# 00-fundamentals/04-variable-validation, reused here specifically to
# demonstrate the native `terraform test` framework against it.

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
