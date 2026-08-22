terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}

# This is the one example in this repo that requires a locally-running
# external process (a `vault server -dev` instance) rather than being
# fully self-contained via `terraform init` alone - see README for setup.
# It's used here because the concept (an ephemeral resource fetching a
# real secret that never touches state) can only be demonstrated against
# a real secrets manager; Vault dev mode is in-memory, listens on
# localhost only, and needs no network access beyond the provider
# download from the registry.

variable "vault_addr" {
  description = "Address of a local Vault dev-mode server (see README for how to start one)."
  type        = string
  default     = "http://127.0.0.1:8299"
}

variable "vault_token" {
  description = "The dev-mode root token - both sensitive AND ephemeral, since it authenticates every request this config makes to Vault and must never be written to plan or state."
  type        = string
  sensitive   = true
  ephemeral   = true
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

ephemeral "vault_kv_secret_v2" "research_app" {
  mount = "secret"
  name  = "research-app"
}

check "secret_has_username" {
  assert {
    condition     = ephemeral.vault_kv_secret_v2.research_app.data.username == "svc-account"
    error_message = "secret/research-app's username did not match the expected value."
  }
}
