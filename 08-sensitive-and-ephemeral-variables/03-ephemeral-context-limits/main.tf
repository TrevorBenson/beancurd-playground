terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

# This example ships only the ALLOWED contexts, since every committed
# main.tf in this repo must validate. The DISALLOWED contexts (which
# produce a plan-time error) are documented with their exact captured
# error text in the README's "try it yourself" section instead of shipped
# here as broken code.

variable "eph_header_value" {
  description = "An ephemeral value used to configure a provider - one of the ALLOWED contexts."
  type        = string
  ephemeral   = true
}

# Context 1 (ALLOWED): provider configuration arguments.
provider "restful" {
  base_url = "https://jsonplaceholder.typicode.com"
  header = {
    Authorization = "Bearer ${var.eph_header_value}"
  }
}

# Context 2 (ALLOWED): another ephemeral resource's own arguments, and its
# own lifecycle postcondition.
ephemeral "restful_resource" "todo" {
  path   = "/todos/1"
  method = "GET"

  lifecycle {
    postcondition {
      condition     = length(var.eph_header_value) > 0
      error_message = "eph_header_value must not be empty."
    }
  }
}

# Context 3 (ALLOWED): check block condition expressions - only the
# pass/fail status is ever persisted to state, never the value used to
# compute it.
check "provider_configured" {
  assert {
    condition     = length(var.eph_header_value) > 0
    error_message = "eph_header_value must not be empty."
  }
}

# Context 4 (ALLOWED): a lifecycle precondition on an ORDINARY resource -
# note the resource's own arguments (`input` below) do NOT reference the
# ephemeral value; only the precondition's boolean condition does. That
# distinction is exactly what makes this allowed.
resource "terraform_data" "gate" {
  input = "static-value"

  lifecycle {
    precondition {
      condition     = length(var.eph_header_value) > 0
      error_message = "eph_header_value must not be empty."
    }
  }
}
