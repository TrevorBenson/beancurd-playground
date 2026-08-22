run "accepts_valid_environment" {
  command = plan

  variables {
    environment = "staging"
  }

  assert {
    condition     = output.environment == "staging"
    error_message = "environment output did not echo the input variable"
  }
}

run "rejects_invalid_environment" {
  command = plan

  variables {
    environment = "bogus"
  }

  expect_failures = [
    var.environment,
  ]
}
