terraform {
  required_version = ">= 1.5.0"
}

# A loosely-typed input object. `type = any` is used deliberately here so
# callers can omit keys - that's exactly the scenario this example exists
# to handle safely.
variable "config" {
  description = "An arbitrary config object that may or may not contain every key."
  type        = any
  default = {
    name   = "example"
    region = "us-east-1"
  }
}

variable "required_key" {
  description = "The key to look for in var.config."
  type        = string
  default     = "region"
}

locals {
  # Approach 1: contains() + keys() - explicit, reads clearly as an
  # existence check, returns a plain bool.
  key_exists_via_contains = contains(keys(var.config), local.required_key)

  # Approach 2: can() + a direct index expression - also a plain bool,
  # and additionally works for keys whose names aren't valid identifiers.
  key_exists_via_can = can(var.config[local.required_key])

  # Reduce indirection below.
  required_key = var.required_key
}

output "key_exists_via_contains" {
  description = "true/false from contains(keys(var.config), required_key)."
  value       = local.key_exists_via_contains
}

output "key_exists_via_can" {
  description = "true/false from can(var.config[required_key])."
  value       = local.key_exists_via_can
}

output "value_or_default" {
  description = "The value at required_key, or a sentinel if it's missing - via try()."
  value       = try(var.config[var.required_key], "KEY_NOT_FOUND")
}
