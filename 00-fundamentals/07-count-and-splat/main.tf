terraform {
  required_version = ">= 1.4.0"
}

# `count` creates N instances of a resource, indexed 0..N-1 and addressed as
# terraform_data.widget[0], [1], etc. A splat expression (resource[*].attr)
# collects one attribute from every instance into a list in one step -
# contrast with 06-for-each-multiple-resources, where instances are keyed by
# a map key instead of a numeric index, and there is no positional splat.

variable "widget_names" {
  description = "Ordered list of widget names to create - one terraform_data instance per entry."
  type        = list(string)
  default     = ["alpha", "beta", "gamma"]
}

resource "terraform_data" "widget" {
  count = length(var.widget_names)
  input = var.widget_names[count.index]
}

output "widget_inputs_splat" {
  description = "Every instance's input, collected via the [*] splat expression."
  value       = terraform_data.widget[*].input
}
