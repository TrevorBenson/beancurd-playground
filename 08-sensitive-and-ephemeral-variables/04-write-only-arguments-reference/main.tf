terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This directory deliberately declares no `provider "aws" {}` block and no
# resources. The only commands ever run here are `terraform init` (to
# download the provider plugin) and `terraform providers schema -json`
# (to read its schema) - both work with zero AWS credentials and make no
# live API calls. See README for why: no zero-dependency provider already
# used in this repo has adopted write-only arguments yet, so this example
# inspects a real provider that has, without ever planning or applying
# against real AWS infrastructure.
