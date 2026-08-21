terraform {
  required_version = ">= 1.4.0"
}

# for_each over a map creates one resource instance per map entry, keyed by
# the map key (available inside the block as `each.key` / `each.value`).
# Uses the built-in terraform_data resource - no external provider needed.

variable "widgets" {
  description = "Map of widget name to its attributes."
  type = map(object({
    size  = string
    color = string
  }))
  default = {
    small_red  = { size = "small", color = "red" }
    large_blue = { size = "large", color = "blue" }
  }
}

resource "terraform_data" "widget" {
  for_each = var.widgets

  input = {
    name  = each.key
    size  = each.value.size
    color = each.value.color
  }
}

output "widget_ids" {
  description = "Map of widget name to its terraform_data resource id, once created."
  value       = { for k, w in terraform_data.widget : k => w.id }
}
