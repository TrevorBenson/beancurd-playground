terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

# Three variables, side by side, each demonstrating a different marking:
#   - plain:               no marking at all
#   - sensitive_only:      sensitive = true, NOT ephemeral
#   - sensitive_ephemeral: sensitive = true AND ephemeral = true
# The sensitive_ephemeral variable is run through every allowed context
# established in 03-ephemeral-context-limits: provider config, an
# ephemeral resource's postcondition, a check block, and an ordinary
# resource's lifecycle precondition.

variable "plain" {
  description = "An ordinary variable - no special handling."
  type        = string
  default     = "plain-value"
}

variable "sensitive_only" {
  description = "sensitive = true, NOT ephemeral - display-redacted, but plaintext in plan and state (see 01-sensitive-variable-plan-vs-state)."
  type        = string
  sensitive   = true
  default     = "sensitive-value"
}

variable "sensitive_ephemeral" {
  description = "sensitive = true AND ephemeral = true - never written to plan or state at all, on top of being display-redacted wherever it briefly could show up."
  type        = string
  sensitive   = true
  ephemeral   = true
}

locals {
  se_local = var.sensitive_ephemeral
}

# Context 1 (provider configuration) - same pattern as 03-ephemeral-context-limits.
provider "restful" {
  base_url = "https://jsonplaceholder.typicode.com"
  header = {
    Authorization = "Bearer ${var.sensitive_ephemeral}"
  }
}

# Context 2 (an ephemeral resource's own postcondition).
ephemeral "restful_resource" "todo" {
  path   = "/todos/1"
  method = "GET"

  lifecycle {
    postcondition {
      condition     = length(var.sensitive_ephemeral) > 3
      error_message = "sensitive_ephemeral must be longer than 3 characters."
    }
  }
}

# Context 3 (a check block).
check "se_check" {
  assert {
    condition     = length(local.se_local) > 3
    error_message = "sensitive_ephemeral must be longer than 3 characters."
  }
}

# Context 4 (a lifecycle precondition on an ordinary resource - note
# `input` below does NOT reference sensitive_ephemeral; only the
# precondition's condition does).
resource "terraform_data" "gate" {
  input = var.plain

  lifecycle {
    precondition {
      condition     = length(var.sensitive_ephemeral) > 3
      error_message = "sensitive_ephemeral must be longer than 3 characters."
    }
  }
}

output "plain_out" {
  value = var.plain
}

output "sensitive_only_out" {
  value     = var.sensitive_only
  sensitive = true
}

# sensitive_ephemeral has NO output here: root modules cannot declare
# ephemeral outputs at all (see 02-ephemeral-resources/01-valid-response),
# and being ephemeral additionally means it could never be assigned to a
# *non*-ephemeral output either - that would itself be "ephemeral value
# used in non-ephemeral context" (see 03-ephemeral-context-limits).
