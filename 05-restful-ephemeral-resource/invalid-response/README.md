# Ephemeral resource: invalid response (401/404)

Same idea as [`valid-response/`](../valid-response), but pointed at
`https://postman-echo.com/status/<code>` - a stable public test endpoint
that returns whatever HTTP status code you ask for. This demonstrates what
happens when `ephemeral "restful_resource"`'s "open" call gets a non-2xx
response: the provider treats it as an error and the plan fails outright
(there's no `output` to reach - it never gets that far).

Requires Terraform/OpenTofu >= 1.10 and real network access.

## Files

- `main.tf` - `variable "status_code"` (default `404`) and
  `ephemeral "restful_resource" "broken"` requesting
  `/status/${var.status_code}`.

## How to test

```bash
terraform init
terraform plan
```

With the default `status_code = 404`, the plan **fails**:

```
Error: Open operation API returns 404
...
{"status":404}
```

Try a 401:

```bash
terraform plan -var status_code=401
```

```
Error: Open operation API returns 401
...
{"status":401}
```

And a passing status code, to see the contrast:

```bash
terraform plan -var status_code=200
```

```
No changes. Your infrastructure matches the configuration.
```
