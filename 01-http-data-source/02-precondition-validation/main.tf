terraform {
  required_version = ">= 1.5.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

# Extends 01-fetch-and-decode-json: same fixed-response endpoint, but adds a
# variable that must match a value found in the *actual* HTTP response.
# A lifecycle precondition on the data source enforces that, using `self`
# to refer back to the data source's own attributes.

variable "expected_todo_id" {
  description = "The 'id' this config expects the fetched todo to have."
  type        = number
  default     = 999 # intentionally wrong - jsonplaceholder.typicode.com/todos/1 always returns id 1
}

data "http" "todo" {
  url = "https://jsonplaceholder.typicode.com/todos/1"

  request_headers = {
    Accept = "application/json"
  }
}

locals {
  todo = jsondecode(data.http.todo.response_body)
}

# `self` is only available in postcondition/provisioner/connection blocks,
# not precondition - a precondition can only see values that are already
# known *before* the block it's attached to is evaluated. So the
# precondition validating the fetched todo id lives on the *output* that
# consumes the data source's result, not on the data source itself.
output "todo_title" {
  value = local.todo.title

  precondition {
    condition     = local.todo.id == var.expected_todo_id
    error_message = "Fetched todo id (${local.todo.id}) does not match expected_todo_id (${var.expected_todo_id})."
  }
}
