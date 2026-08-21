terraform {
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

variable "path" {
  type = string
}

variable "expected_completed" {
  description = "The value the caller expects ephemeral.restful_resource.item.output.completed to have."
  type        = bool
}

ephemeral "restful_resource" "item" {
  path   = var.path
  method = "GET"
}

# `self` is only valid in postcondition/provisioner/connection blocks, so a
# precondition validating the ephemeral resource's own response can't be
# attached to the ephemeral resource itself. Instead it's attached here, to
# the module output that consumes it - referencing the ephemeral resource
# directly (not via `self`) is fine, since this isn't a self-reference.
output "title" {
  value     = ephemeral.restful_resource.item.output.title
  ephemeral = true

  precondition {
    condition     = ephemeral.restful_resource.item.output.completed == var.expected_completed
    error_message = "ephemeral.restful_resource.item.output.completed did not match expected_completed (${var.expected_completed})."
  }
}
