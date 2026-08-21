terraform {
  required_version = ">= 1.5.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

# jsonplaceholder.typicode.com is a free, stable fake-REST-API used widely
# in examples/tutorials. /todos/1 always returns the same fixed JSON body:
#   {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
# This is the one example in this repo that requires real network access -
# per the repo convention, external dependencies are used here because the
# concept (parsing a real HTTP JSON response) can't be demonstrated with a
# mock.

data "http" "todo" {
  url = "https://jsonplaceholder.typicode.com/todos/1"

  request_headers = {
    Accept = "application/json"
  }
}

locals {
  todo = jsondecode(data.http.todo.response_body)
}

output "todo_status_code" {
  value = data.http.todo.status_code
}

output "todo_title" {
  description = "Accessing a known key ('title') from the decoded JSON body."
  value       = local.todo.title
}

output "todo_completed" {
  value = local.todo.completed
}
