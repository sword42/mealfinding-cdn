## 1. Project Setup

- [ ] 1.1 Update `.gitignore` with Terraform patterns (*.tfstate, .terraform/, *.tfvars, .env)
- [ ] 1.2 Create `terraform/` directory structure
- [ ] 1.3 Create `scripts/` directory

## 2. State Backend Setup

- [ ] 2.1 Create `scripts/setup-tigris.sh` to provision Tigris bucket
- [ ] 2.2 Document Tigris credential setup in README

## 3. Terraform Configuration

- [ ] 3.1 Create `terraform/providers.tf` with Fastly provider and Tigris S3 backend
- [ ] 3.2 Create `terraform/variables.tf` with domain, origin, and TTL variables
- [ ] 3.3 Create `terraform/main.tf` with Fastly VCL service resource
  - [ ] 3.3.1 Configure domains (apex, www, api)
  - [ ] 3.3.2 Configure backends (web_origin, api_origin)
  - [ ] 3.3.3 Configure conditions for routing and content types
  - [ ] 3.3.4 Configure cache settings per content type
  - [ ] 3.3.5 Configure security headers (HSTS, CSP, X-Frame-Options, etc.)
  - [ ] 3.3.6 Configure gzip compression
- [ ] 3.4 Create `terraform/tls.tf` with TLS subscription for Let's Encrypt certificates
- [ ] 3.5 Create `terraform/outputs.tf` with service ID, domains, CNAME, TLS challenges

## 4. VCL Configuration

- [ ] 4.1 Create `terraform/vcl/` directory
- [ ] 4.2 Create `terraform/vcl/main.vcl` with:
  - [ ] 4.2.1 Subdomain-based backend routing (vcl_recv)
  - [ ] 4.2.2 HTTPS redirect logic
  - [ ] 4.2.3 Cache key optimization (vcl_hash)
  - [ ] 4.2.4 Content-type TTL rules (vcl_fetch)
  - [ ] 4.2.5 Cache status headers (vcl_deliver)
  - [ ] 4.2.6 Custom error pages (vcl_error)

## 5. Documentation

- [ ] 5.1 Create `terraform/README.md` with:
  - [ ] 5.1.1 Prerequisites section
  - [ ] 5.1.2 Initial setup instructions (Tigris, env vars)
  - [ ] 5.1.3 Terraform workflow (init, plan, apply)
  - [ ] 5.1.4 DNS configuration guide
  - [ ] 5.1.5 Caching strategy documentation
  - [ ] 5.1.6 Troubleshooting section

## 6. Validation

- [ ] 6.1 Run `terraform fmt` to format configuration
- [ ] 6.2 Run `terraform validate` to check syntax
- [ ] 6.3 Run `terraform plan` to preview changes (requires credentials)

## Dependencies

- Tasks 3.x depend on 1.x (directory structure)
- Task 3.3 depends on 4.2 (VCL file must exist for main.tf reference)
- Task 6.x depends on all 3.x tasks

## Parallelizable Work

- Tasks 3.1, 3.2, 3.4, 3.5 can be done in parallel
- Tasks 4.2.x can be done in parallel
- Tasks 5.1.x can be done in parallel
