variable "name" {
  description = "Name of this widget instance."
  type        = string
}

variable "size" {
  description = "Size of this widget instance."
  type        = string
  default     = "medium"
}

resource "terraform_data" "widget" {
  input = {
    name = var.name
    size = var.size
  }
}

output "id" {
  value = terraform_data.widget.id
}

output "summary" {
  value = "${var.name} (${var.size})"
}
