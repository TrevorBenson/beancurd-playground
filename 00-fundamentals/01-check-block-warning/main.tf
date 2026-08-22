terraform {
  required_version = ">= 1.5.0"
}

# A "check" block runs an assertion during plan and apply. Unlike a
# lifecycle precondition/postcondition, a failed check never blocks the
# operation - it only surfaces a warning. This is the idiomatic way to
# implement "soft" guardrails (capacity limits, deprecation notices, etc.)
# that authors should notice but that shouldn't stop a plan/apply.

variable "max_widgets" {
  description = "Number of widgets this (fictional) config would provision."
  type        = number
  default     = 150
}

locals {
  soft_limit = 100
}

check "widget_count_within_soft_limit" {
  assert {
    condition     = var.max_widgets <= local.soft_limit
    error_message = "max_widgets (${var.max_widgets}) exceeds the recommended soft limit of ${local.soft_limit}. The plan will still proceed - review capacity before applying."
  }
}

output "max_widgets" {
  value = var.max_widgets
}
