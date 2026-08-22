terraform {
  required_version = ">= 1.4.0"
}

# Terraform infers ordering automatically whenever one resource's
# configuration references another's attribute. `depends_on` is the escape
# hatch for the remaining case: two resources with a real ordering
# requirement that isn't visible in any attribute reference (e.g. `second`
# needs `first` to exist first for a side effect outside Terraform's view,
# not because it reads any of `first`'s values). Uses the built-in
# terraform_data resource - no external provider or real infrastructure
# involved.

resource "terraform_data" "first" {
  input = "first"
}

resource "terraform_data" "second" {
  input = "second" # NOT derived from terraform_data.first - no implicit dependency exists

  depends_on = [terraform_data.first]
}

output "first_id" {
  value = terraform_data.first.id
}

output "second_id" {
  value = terraform_data.second.id
}
