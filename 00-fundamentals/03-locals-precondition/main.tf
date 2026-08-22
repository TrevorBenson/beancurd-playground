terraform {
  required_version = ">= 1.4.0"
}

# terraform_data is the built-in "no-op" resource (part of the implicit
# `terraform.io/builtin/terraform` provider, no external dependency) - it
# exists specifically so examples like this don't need a real cloud
# resource just to hang a `lifecycle` block off of.

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "actual_replica_count" {
  description = "The replica count this (fictional) config would actually set."
  type        = number
  default     = 1
}

locals {
  # One local derived from input, one hardcoded "policy" local. A
  # lifecycle precondition compares them and fails the plan if they
  # disagree - e.g. enforcing "production must run 3 replicas".
  expected_replica_count = var.environment == "production" ? 3 : 1
  actual_replica_count   = var.actual_replica_count
}

resource "terraform_data" "replica_count_check" {
  input = local.actual_replica_count

  lifecycle {
    precondition {
      condition     = local.actual_replica_count == local.expected_replica_count
      error_message = "actual_replica_count (${local.actual_replica_count}) does not match the expected_replica_count (${local.expected_replica_count}) for environment '${var.environment}'."
    }
  }
}

output "expected_replica_count" {
  value = local.expected_replica_count
}

output "actual_replica_count" {
  value = local.actual_replica_count
}
