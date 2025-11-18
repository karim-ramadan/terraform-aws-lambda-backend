# Terraform Module Tests

This directory contains tests for the Terraform AWS Lambda Backend module using Terraform's built-in testing framework.

## Test Files

- `basic.tftest.hcl` - Basic module structure and output validation tests
- `variables.tftest.hcl` - Variable validation tests

## Running Tests

### Prerequisites

- Terraform >= 1.6.0 (required for built-in testing support)
- AWS credentials configured (for tests that require AWS resources)

### Run All Tests

```bash
terraform test
```

### Run Specific Test File

```bash
terraform test tests/basic.tftest.hcl
terraform test tests/variables.tftest.hcl
```

### Run Tests with Verbose Output

```bash
terraform test -verbose
```

## Test Structure

Tests use Terraform's built-in testing framework (`.tftest.hcl` files) which:
- Run `terraform plan` by default (no actual resources are created)
- Can validate module structure, outputs, and variables
- Can assert conditions about the planned resources
- Require AWS credentials for planning (but don't create resources)

## Note

These tests are designed to validate the module structure and configuration without requiring actual AWS resources to be created. For integration tests that create real resources, you would need to use a different testing framework or run these tests in a dedicated test AWS account.

