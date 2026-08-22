terraform {
  required_version = ">= 1.4.0"
}

# A `moved` block tells Terraform "the object that used to be at `from` is
# now configured at `to`" - so a rename in configuration doesn't get
# mistaken for "destroy the old one, create a new one". Uses the built-in
# terraform_data resource - no external provider or real infrastructure
# involved.
#
# This resource's name was renamed from `widget_new` to `widget_renamed`.
# Without the moved block below, that rename alone would cause OpenTofu to
# plan a destroy-then-create (see the README for a side-by-side
# demonstration).

resource "terraform_data" "widget_renamed" {
  input = "widget-a"
}

moved {
  from = terraform_data.widget_new
  to   = terraform_data.widget_renamed
}
