terraform {
  required_version = ">= 1.5.0"
}

# sensitive = true is a DISPLAY-ONLY redaction: the CLI hides the value in
# plan/apply console output and in `terraform output`, but the real
# plaintext value is present, unredacted, in both `terraform show -json`
# on a saved plan file AND on the state file - see this example's README
# for the exact commands proving it.

variable "api_key" {
  description = "A secret value - sensitive, but NOT ephemeral."
  type        = string
  default     = "SUPER-SECRET-VALUE-12345"
  sensitive   = true
}

variable "plain_note" {
  description = "A non-secret value, for contrast."
  type        = string
  default     = "not-secret-value"
}

resource "terraform_data" "config" {
  input = var.api_key
}

output "api_key_out" {
  value     = terraform_data.config.output
  sensitive = true
}

output "plain_note_out" {
  value = var.plain_note
}
