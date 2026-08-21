terraform {
  required_version = ">= 1.5.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

# Combines 01-fetch-and-decode-json (data "http" against a known-fixed
# endpoint) with 00-fundamentals/06-for-each-multiple-resources (for_each):
# fetches several jsonplaceholder.typicode.com todos in a single plan.
#
# for_each on a data source requires a set of strings (or a map), so the
# variable is declared as set(string) even though the values are numeric
# ids.

variable "todo_ids" {
  description = "Which jsonplaceholder.typicode.com/todos/<id> to fetch."
  type        = set(string)
  default     = ["1", "2", "3"]
}

data "http" "todo" {
  for_each = var.todo_ids

  url = "https://jsonplaceholder.typicode.com/todos/${each.key}"

  request_headers = {
    Accept = "application/json"
  }
}

locals {
  todos = { for id, resp in data.http.todo : id => jsondecode(resp.response_body) }
}

output "todo_titles" {
  description = "Map of todo id to its title, for every id in var.todo_ids."
  value       = { for id, todo in local.todos : id => todo.title }
}
