# Provider aliases: multiple configurations of the same provider

Demonstrates configuring the same provider (`magodo/restful`, already used
in [`02-ephemeral-resources`](../../02-ephemeral-resources)) twice, each
with a different `alias` and a different `base_url`, and picking a specific
configuration per-resource with `provider = restful.<alias>`. Requires real
network access to both `jsonplaceholder.typicode.com` and
`postman-echo.com`, and Terraform/OpenTofu >= 1.10 (ephemeral resources).

## Why this needs an alias

Normally a provider is configured once (the "default" configuration), and
every resource of that type implicitly uses it. When you need two
*different* configurations of the same provider type at once - here, two
different `base_url`s - each extra configuration needs its own `alias` to
distinguish it, and each resource/data/ephemeral block that should use a
non-default configuration must say so explicitly via `provider = <type>.<alias>`.
Anything that omits `provider` would need a non-aliased default
configuration to fall back to; this example has none (both configurations
are aliased), so every block here must specify one.

## Files

- `main.tf` - two `provider "restful"` blocks, aliased `jsonplaceholder`
  and `postmanecho`, and two `ephemeral "restful_resource"` blocks, each
  pinned to one alias via `provider = restful.<alias>`.

## How to test

```bash
terraform init
terraform plan
```

Expect both ephemeral resources to open and close successfully against
their respective real endpoints, with a clean plan:

```
ephemeral.restful_resource.todo: Opening...
ephemeral.restful_resource.status: Opening...
ephemeral.restful_resource.todo: Open complete after 0s
ephemeral.restful_resource.todo: Closing...
ephemeral.restful_resource.todo: Close complete after 0s
ephemeral.restful_resource.status: Open complete after 0s
ephemeral.restful_resource.status: Closing...
ephemeral.restful_resource.status: Close complete after 0s

No changes. Your infrastructure matches the configuration.
```
