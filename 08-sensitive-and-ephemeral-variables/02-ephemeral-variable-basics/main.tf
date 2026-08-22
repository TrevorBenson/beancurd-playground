terraform {
  required_version = ">= 1.10.0" # ephemeral variables require Terraform/OpenTofu >= 1.10
}

# ephemeral = true is a REAL omission, not a display trick: a genuinely
# runtime-supplied ephemeral variable's value is completely absent from
# both the saved plan file and the state file - not redacted, not marked,
# just not there at all. See this example's README for the exact commands
# proving it, and for the one common mistake (hardcoding a real secret as
# a literal `default =`) that defeats this guarantee regardless of the
# ephemeral marking.

variable "eph_token" {
  description = "An ephemeral value. Deliberately has NO default - see README for why."
  type        = string
  ephemeral   = true
}

variable "plain_note" {
  type    = string
  default = "not-secret-value"
}

resource "terraform_data" "config" {
  input = var.plain_note
}

locals {
  eph_local = var.eph_token
}

# check blocks are one of the sanctioned contexts an ephemeral value CAN
# be used in - see 03-ephemeral-context-limits for the contexts this tier
# demonstrates (not an exhaustive catalog).
check "eph_check" {
  assert {
    condition     = length(local.eph_local) > 0
    error_message = "eph_token must not be empty."
  }
}

output "plain_note_out" {
  value = var.plain_note
}
