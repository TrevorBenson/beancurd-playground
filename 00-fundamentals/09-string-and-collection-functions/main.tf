terraform {
  required_version = ">= 1.5.0"
}

# A tour of commonly-needed string/collection functions and templatefile():
# join()/merge()/lookup() for combining and reading maps, a for-expression
# for reshaping a map into a list of strings, and templatefile() for
# rendering an external template file with variables.

variable "user_config" {
  description = "An arbitrary user-supplied config map."
  type        = map(string)
  default = {
    name = "Ada"
    role = "admin"
  }
}

locals {
  # join() + a for-expression: reshape a map into "key=value, key=value".
  summary = join(", ", [for k, v in var.user_config : "${k}=${v}"])

  # merge(): combine two maps, with the second map's keys winning on conflict.
  merged = merge(var.user_config, { extra = "yes" })

  # lookup(): read a key with a fallback default instead of erroring if it's absent.
  greeting_name = lookup(var.user_config, "name", "stranger")

  # templatefile(): render an external template file, passing it named variables.
  greeting = templatefile("${path.module}/greeting.tftpl", {
    name  = local.greeting_name
    count = 3
  })
}

output "summary" {
  value = local.summary
}

output "merged" {
  value = local.merged
}

output "greeting" {
  value = local.greeting
}
