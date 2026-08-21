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

# jsonplaceholder.typicode.com/todos/1 always returns the same fixed body:
#   {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
# (same endpoint used via `data "http"` in 04-data-http-json-key.)
module "todo" {
  source = "./modules/todo-fetcher"
  path   = "/todos/1"
}

# `check` blocks accept ephemeral values in their conditions, so this is a
# convenient, self-contained way to prove the ephemeral resource's "title"
# key was actually read - if the assertion is wrong, the fetched value
# shows up right in the warning/error message.
check "todo_title_matches_known_value" {
  # NOTE: error_message deliberately doesn't interpolate module.todo.title -
  # OpenTofu/Terraform refuses to render ephemeral values into messages
  # (see the README for what happens if you try).
  assert {
    condition     = module.todo.title == "delectus aut autem"
    error_message = "Fetched todo title did not match the known, fixed value from jsonplaceholder.typicode.com/todos/1."
  }
}

check "todo_completed_matches_known_value" {
  assert {
    condition     = module.todo.completed == false
    error_message = "Fetched todo 'completed' flag did not match the known, fixed value from jsonplaceholder.typicode.com/todos/1."
  }
}
