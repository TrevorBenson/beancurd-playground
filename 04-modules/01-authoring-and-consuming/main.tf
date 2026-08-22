terraform {
  required_version = ">= 1.4.0"
}

# A minimal reusable module (./modules/widget) with its own inputs/outputs,
# consumed from the root with for_each - one module instance per map entry,
# exactly like a resource with for_each (see
# 00-fundamentals/06-for-each-multiple-resources). Uses the built-in
# terraform_data resource inside the module - no external provider or real
# infrastructure involved.

variable "widgets" {
  description = "Map of widget name to its attributes."
  type = map(object({
    size = string
  }))
  default = {
    small_red  = { size = "small" }
    large_blue = { size = "large" }
  }
}

module "widget" {
  source   = "./modules/widget"
  for_each = var.widgets

  name = each.key
  size = each.value.size
}

output "widget_summaries" {
  description = "One summary string per widget, read from each module instance's own output."
  value       = { for k, m in module.widget : k => m.summary }
}
