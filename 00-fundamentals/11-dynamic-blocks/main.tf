terraform {
  required_version = ">= 1.5.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# `dynamic` blocks generate a variable number of *nested configuration
# blocks* (as opposed to `for_each`/`count`, which generate a variable
# number of *resource instances*). They only work where a provider's schema
# actually defines a repeatable nested block - most provider-free/built-in
# resources don't have one, so this example uses hashicorp/tls, which
# computes everything locally (a private key and a self-signed cert) with
# no network calls and no real infrastructure, purely to get access to a
# resource with a genuine repeatable nested block (`subject`).
#
# NOTE: `dynamic` blocks do NOT work for `provisioner`, `connection`, or
# `lifecycle` blocks - only for a resource/data/provider's own
# provider-defined nested block types.

variable "include_subject" {
  description = "Whether to attach a subject block to the certificate at all - demonstrates using dynamic to conditionally emit 0 or 1 nested blocks."
  type        = bool
  default     = true
}

variable "subject_common_name" {
  type    = string
  default = "example.internal"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem       = tls_private_key.example.private_key_pem
  validity_period_hours = 24
  allowed_uses          = ["cert_signing"]

  dynamic "subject" {
    for_each = var.include_subject ? [var.subject_common_name] : []
    content {
      common_name = subject.value
    }
  }
}

output "cert_has_subject" {
  value = length(tls_self_signed_cert.example.subject) > 0
}
