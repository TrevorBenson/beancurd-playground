terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

provider "restful" {
  base_url = "https://jsonplaceholder.typicode.com"
}

# This capstone chains six concepts from earlier tiers around one shared
# input, var.todo_id:
#   1. variable validation      (00-fundamentals/04-variable-validation)
#   2. check-block warning      (00-fundamentals/01-check-block-warning)
#   3. data "http" + jsondecode (01-http-data-source/01-fetch-and-decode-json)
#   4. output precondition      (01-http-data-source/02-precondition-validation)
#   5. ephemeral resource fetch (02-ephemeral-resources/01-valid-response)
#   6. postcondition with self  (00-fundamentals/05-postcondition-self)

variable "todo_id" {
  description = "Which jsonplaceholder.typicode.com/todos/<id> to fetch."
  type        = number
  default     = 1

  validation {
    condition     = var.todo_id > 0
    error_message = "todo_id must be a positive integer."
  }
}

variable "expected_title" {
  description = "The title this config expects todo_id to have."
  type        = string
  default     = "delectus aut autem" # correct for todo_id = 1
}

# --- Step A: fetch via data "http", decode, and check for a soft guardrail ---

data "http" "todo" {
  url = "https://jsonplaceholder.typicode.com/todos/${var.todo_id}"

  request_headers = {
    Accept = "application/json"
  }
}

locals {
  todo = jsondecode(data.http.todo.response_body)
}

check "todo_not_already_completed" {
  assert {
    condition     = local.todo.completed == false
    error_message = "todo ${var.todo_id} is already marked completed - downstream automation may skip it."
  }
}

output "todo_title" {
  value = local.todo.title

  precondition {
    condition     = local.todo.title == var.expected_title
    error_message = "Fetched title '${local.todo.title}' did not match expected_title '${var.expected_title}'."
  }
}

# --- Step B: fetch the same todo again via an ephemeral resource, with a
# --- postcondition validating its own response using self ---

ephemeral "restful_resource" "todo" {
  path   = "/todos/${var.todo_id}"
  method = "GET"

  lifecycle {
    postcondition {
      condition     = self.output.id == var.todo_id
      error_message = "Ephemeral fetch id did not match expected todo_id (${var.todo_id})."
    }
  }
}
