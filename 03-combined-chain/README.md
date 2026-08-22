# Combined chain

A capstone tier: examples here don't introduce new Terraform concepts on
their own - they wire together concepts from `00-fundamentals`,
`01-http-data-source`, and `02-ephemeral-resources` into a single flow, the
way a real module usually combines several of these patterns at once.

- [`01-full-pipeline`](01-full-pipeline) - variable validation, a `check`
  warning, a `data "http"` fetch + precondition, and an ephemeral resource
  fetch + postcondition, all validating the same input from different
  angles.
