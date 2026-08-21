terraform {
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

variable "path" {
  type = string
}

# Ephemeral resources are opened fresh for every plan/apply and never
# persisted to state.
ephemeral "restful_resource" "item" {
  path   = var.path
  method = "GET"
}

# Root modules cannot declare ephemeral outputs, but non-root modules can -
# the calling module can then use the value anywhere ephemeral values are
# accepted (e.g. a root-level `check` block, another ephemeral resource, a
# write-only resource argument).
output "title" {
  value     = ephemeral.restful_resource.item.output.title
  ephemeral = true
}

output "completed" {
  value     = ephemeral.restful_resource.item.output.completed
  ephemeral = true
}
