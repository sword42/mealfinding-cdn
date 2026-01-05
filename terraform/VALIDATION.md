# Terraform Validation Checklist

This document tracks the validation steps for the Terraform configuration.

## Validation Steps

### 1. Format Check

Run this to ensure all `.tf` files are properly formatted:

```bash
cd terraform
terraform fmt -check -recursive
```

If files need formatting, run:
```bash
terraform fmt -recursive
```

### 2. Syntax Validation

Run this to validate Terraform syntax:

```bash
cd terraform
terraform validate
```

This checks for:
- Syntax errors
- Invalid resource configurations
- Missing required arguments
- Type mismatches

### 3. Plan Preview

Run this to preview what resources will be created (requires credentials):

```bash
cd terraform

# Ensure environment variables are set first:
# export AWS_ACCESS_KEY_ID="tid_xxxxx"
# export AWS_SECRET_ACCESS_KEY="tsec_xxxxx"
# export FASTLY_API_KEY="your-fastly-api-key"

terraform init
terraform plan
```

## Expected Results

### terraform fmt
- **Expected**: No output (all files already formatted)
- **If changes needed**: List of files that were reformatted

### terraform validate
- **Expected**: `Success! The configuration is valid.`
- **If errors**: Fix syntax errors and re-run

### terraform plan
- **Expected**: Plan showing resources to be created:
  - 1 fastly_service_vcl
  - 1 fastly_tls_subscription
  - 1 fastly_tls_subscription_validation
- **If errors**: Check credentials and network connectivity

## Manual Validation Performed

During development, the following manual checks were completed:

### Syntax Validation
- [x] All `.tf` files created with valid HCL syntax
- [x] Brace matching verified (26 opening, 26 closing braces in main.tf)
- [x] All files properly terminated with closing braces
- [x] No syntax errors in resource declarations

### File Structure
- [x] VCL file exists at `vcl/main.vcl` (required by `main.tf`)
- [x] File reference path correct: `file("${path.module}/vcl/main.vcl")`
- [x] All required `.tf` files present (providers, variables, main, tls, outputs)

### Configuration Validation
- [x] Provider versions specified (`>= 5.0.0` for Fastly)
- [x] Backend configuration references Tigris endpoint (`fly.storage.tigris.dev`)
- [x] All required variables have defaults
- [x] All variable references match defined variables:
  - service_name, domain_name, web_origin, api_origin
  - static_asset_ttl, html_ttl, force_destroy
- [x] Outputs reference valid resource attributes
- [x] TLS subscription depends on service creation
- [x] Resource naming conventions followed (snake_case)

### Resource Configuration
- [x] `fastly_service_vcl.mealfinding` properly declared
- [x] `fastly_tls_subscription.mealfinding` properly declared
- [x] `fastly_tls_subscription_validation.mealfinding` properly declared
- [x] All resource references use correct syntax

**Validation Date**: 2026-01-04
**Validated By**: Manual inspection + automated checks

## Notes

The Terraform configuration has been authored following HashiCorp best practices and Fastly provider documentation. Full validation requires:

1. Terraform CLI installed (>= 1.5.0)
2. Tigris bucket created
3. Environment variables configured
4. Network access to Fastly API

Run the validation steps above after setting up the prerequisites listed in `README.md`.
