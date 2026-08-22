terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

provider "restful" {
  base_url = "https://jsonplaceholder.typicode.com"
}

# Extends 01-valid-response: same fixed endpoint and ephemeral resource,
# plus a variable that must match a value found in the *actual* ephemeral
# response, enforced by a lifecycle precondition.

variable "expected_completed" {
  description = "Expected value of the fetched todo's 'completed' flag."
  type        = bool
  default     = true # intentionally wrong - jsonplaceholder.typicode.com/todos/1 always returns completed=false
}

module "todo" {
  source             = "./modules/todo-fetcher"
  path               = "/todos/1"
  expected_completed = var.expected_completed
}
