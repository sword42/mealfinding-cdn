# Change: Add Fastly CDN Infrastructure with Terraform

## Why

The Mealfinding platform requires CDN and DDoS protection to serve the public website (mealfinding.com, www.mealfinding.com) and REST API (api.mealfinding.com) with optimal performance, security, and reliability. Terraform enables infrastructure-as-code management for reproducible, version-controlled CDN configuration.

## What Changes

- Add Terraform configuration for Fastly CDN service
- Configure Fly.io Tigris as S3-compatible Terraform state backend
- Set up subdomain-based routing to separate fly.io origins (web vs API)
- Implement optimized caching strategies for static assets, SSG HTML, and API responses
- Configure TLS/SSL certificates via Let's Encrypt
- Add security headers (HSTS, CSP, X-Frame-Options, etc.)
- Create custom VCL for routing, cache optimization, and error handling
- Add setup scripts and documentation

## Impact

- **Affected specs**: Creates new `cdn-infrastructure` and `cdn-routing` capabilities
- **Affected code**:
  - New `terraform/` directory with Fastly configuration
  - New `scripts/` directory with setup utilities
  - Updated `.gitignore` for Terraform patterns
- **External dependencies**:
  - Fastly account with API token
  - Fly.io Tigris storage bucket
  - DNS configuration for mealfinding.com
