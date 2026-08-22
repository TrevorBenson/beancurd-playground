terraform {
  required_version = ">= 1.10.0" # ephemeral resources require Terraform/OpenTofu >= 1.10
  required_providers {
    restful = {
      source  = "magodo/restful"
      version = "~> 0.20"
    }
  }
}

# A provider can be configured more than once, each configuration
# distinguished by an `alias`. Resources/data/ephemeral blocks pick a
# specific configuration via `provider = <type>.<alias>`; anything that
# omits `provider` uses the one un-aliased ("default") configuration
# instead. Here, the same magodo/restful provider is configured twice,
# pointed at the two different stable endpoints already used elsewhere in
# this repo, and each ephemeral resource picks one explicitly.

provider "restful" {
  alias    = "jsonplaceholder"
  base_url = "https://jsonplaceholder.typicode.com"
}

provider "restful" {
  alias    = "postmanecho"
  base_url = "https://postman-echo.com"
}

ephemeral "restful_resource" "todo" {
  provider = restful.jsonplaceholder
  path     = "/todos/1"
  method   = "GET"
}

ephemeral "restful_resource" "status" {
  provider = restful.postmanecho
  path     = "/status/200"
  method   = "GET"
}
