terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

# postman-echo.com/status/<code> is a stable public test endpoint that
# simply returns whatever status code you ask for. `restful_resource`
# (like most REST-aware providers) treats a non-2xx response from an
# "open" call as an error - it does not silently return it.

variable "status_code" {
  description = "HTTP status code to request from postman-echo.com/status/<code>. Try 200, 401, or 404."
  type        = number
  default     = 404
}

provider "restful" {
  base_url = "https://postman-echo.com"
}

ephemeral "restful_resource" "broken" {
  path   = "/status/${var.status_code}"
  method = "GET"
}
