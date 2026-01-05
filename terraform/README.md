# Mealfinding CDN - Terraform Configuration

This directory contains Terraform configuration for the Mealfinding Fastly CDN infrastructure.

## Prerequisites

Before you begin, ensure you have:

1. **Fly.io CLI** installed and authenticated
   ```bash
   # Install (macOS)
   brew install flyctl

   # Authenticate
   flyctl auth login
   ```

2. **Terraform** >= 1.5.0 installed
   ```bash
   # Install (macOS)
   brew install terraform

   # Verify
   terraform version
   ```

3. **Fastly API Key** with write permissions
   - Create at: https://manage.fastly.com/account/personal/tokens
   - Requires scope: `global` or `global:read global:write`

4. **Domain access** to configure DNS records for `mealfinding.com`

## Initial Setup

### Step 1: Create Tigris Bucket for State Storage

Run the setup script to create a Tigris bucket for Terraform state:

```bash
cd /path/to/mealfinding-cdn
./scripts/setup-tigris.sh
```

This will output Tigris credentials. **Save them securely** - you'll need them in the next step.

### Step 2: Configure Environment Variables

Set the following environment variables in your shell:

```bash
# Tigris credentials (from setup-tigris.sh output)
export AWS_ACCESS_KEY_ID="tid_xxxxx"
export AWS_SECRET_ACCESS_KEY="tsec_xxxxx"

# Fastly API key
export FASTLY_API_KEY="your-fastly-api-key"
```

**Tip**: Add these to your `~/.zshrc` or `~/.bashrc` for persistence, or use a tool like `direnv`.

### Step 3: Initialize Terraform

```bash
cd terraform
terraform init
```

This will:
- Download the Fastly provider
- Initialize the Tigris S3 backend
- Prepare the working directory

### Step 4: Review the Plan

```bash
terraform plan
```

Review the resources that will be created:
- 1 Fastly VCL service
- 1 TLS subscription (Let's Encrypt)
- Domains, backends, cache settings, headers, etc.

### Step 5: Apply Configuration

```bash
terraform apply
```

Type `yes` to confirm and create the resources.

**Note**: The initial apply will create the Fastly service but TLS validation will be pending until DNS is configured.

### Step 6: Configure DNS

After the first `terraform apply`, you'll see outputs including DNS records needed for:

1. **CNAME records** (point domains to Fastly):
   ```
   mealfinding.com       CNAME  mealfinding.com.global.prod.fastly.net.
   www.mealfinding.com   CNAME  mealfinding.com.global.prod.fastly.net.
   api.mealfinding.com   CNAME  mealfinding.com.global.prod.fastly.net.
   ```

2. **TLS validation records** (from `tls_dns_challenges` output):
   ```bash
   terraform output tls_dns_challenges
   ```

Add these DNS records to your DNS provider (e.g., Cloudflare, Route53, etc.).

### Step 7: Complete TLS Validation

After DNS propagation (usually 5-30 minutes):

```bash
terraform apply
```

This will complete TLS certificate validation. Check the status:

```bash
terraform output tls_state
# Should show: "issued"
```

## Terraform Workflow

### Making Changes

1. Edit Terraform files (`.tf`)
2. Review changes: `terraform plan`
3. Apply changes: `terraform apply`

### Viewing Current State

```bash
# Show all resources
terraform show

# Show specific outputs
terraform output service_id
terraform output fastly_cname
terraform output tls_dns_challenges
```

### Formatting Code

```bash
terraform fmt
```

### Validating Configuration

```bash
terraform validate
```

## Caching Strategy

| Content Type | TTL | Stale-While-Revalidate | Notes |
|--------------|-----|------------------------|-------|
| Static assets (JS, CSS, images, fonts) | 24 hours | 7 days | Query strings stripped for better cache hit ratio |
| HTML pages (SSG) | 1 hour | 1 hour | For AstroJS statically generated content |
| API responses | Pass-through | N/A | Respects origin `Cache-Control` headers, no caching by default |

### Adjusting Cache TTLs

Edit `variables.tf` to change default TTL values:

```hcl
variable "static_asset_ttl" {
  default = 86400  # 24 hours in seconds
}

variable "html_ttl" {
  default = 3600   # 1 hour in seconds
}
```

Then run `terraform apply` to update.

## Architecture

### Domains

- `mealfinding.com` (apex) → `mealfinding-web.fly.dev`
- `www.mealfinding.com` → `mealfinding-web.fly.dev`
- `api.mealfinding.com` → `mealfinding-api.fly.dev`

### Routing Logic

Subdomain-based routing is handled via custom VCL (`vcl/main.vcl`):
- Requests to `api.mealfinding.com` are routed to `api_origin` backend
- Requests to `www` or apex are routed to `web_origin` backend

### Security Features

- **HTTPS enforcement**: All HTTP requests are redirected to HTTPS (301)
- **HSTS**: Strict-Transport-Security header with preload
- **Security headers**: X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- **CSP**: Content-Security-Policy (basic, customizable in `main.tf`)
- **Origin shielding**: Enabled at IAD-VA-US POP for cache efficiency

### VCL Customization

To modify routing or caching logic, edit `vcl/main.vcl` and run `terraform apply`.

## Troubleshooting

### TLS Validation Stuck at "pending"

**Symptoms**: `tls_state` output shows `pending` instead of `issued`

**Solutions**:
1. Verify DNS records are correctly configured:
   ```bash
   dig +short _acme-challenge.mealfinding.com
   ```
2. Wait up to 24 hours for Let's Encrypt validation
3. Check DNS propagation: https://dnschecker.org
4. Review Fastly's TLS troubleshooting: https://docs.fastly.com/en/guides/tls-troubleshooting

### "InvalidAccessKeyId" Error (Tigris)

**Symptoms**: Terraform init fails with Tigris authentication error

**Solutions**:
1. Verify environment variables are set:
   ```bash
   echo $AWS_ACCESS_KEY_ID
   echo $AWS_SECRET_ACCESS_KEY
   ```
2. Ensure credentials start with `tid_` and `tsec_`
3. Re-run `scripts/setup-tigris.sh` to get fresh credentials

### Terraform State Lock Issues

**Symptoms**: "Error locking state" or "state is already locked"

**Solutions**:
1. If a previous operation crashed, force unlock:
   ```bash
   terraform force-unlock LOCK_ID
   ```
2. Ensure no other Terraform operations are running

### DNS Not Resolving to Fastly

**Symptoms**: Domains still pointing to old servers

**Solutions**:
1. Verify CNAME records are configured correctly
2. Check DNS propagation (can take 24-48 hours globally)
3. Clear local DNS cache:
   ```bash
   # macOS
   sudo dscacheutil -flushcache

   # Linux
   sudo systemd-resolve --flush-caches
   ```
4. Test with external DNS checker: https://dnschecker.org

### Fastly API Rate Limits

**Symptoms**: "rate limit exceeded" errors

**Solutions**:
1. Wait a few minutes before retrying
2. Use `terraform plan` more frequently to avoid repeated `apply` operations

### Configuration Validation Errors

**Symptoms**: `terraform validate` fails

**Solutions**:
1. Run `terraform fmt` to fix formatting issues
2. Check syntax in `.tf` files
3. Ensure VCL file exists at `vcl/main.vcl`
4. Review error messages for specific line numbers

## Useful Commands

```bash
# View all outputs
terraform output

# View specific output in JSON
terraform output -json tls_dns_challenges

# Refresh state from remote
terraform refresh

# Import existing resource (if needed)
terraform import fastly_service_vcl.mealfinding SERVICE_ID

# Destroy all resources (DANGEROUS - use with caution)
terraform destroy
```

## Security Notes

- **Never commit** `.tfstate`, `.tfvars`, or `.env` files to git (excluded via `.gitignore`)
- Store Fastly API keys and Tigris credentials securely (use environment variables or a secrets manager)
- Rotate API keys periodically
- Use `force_destroy = false` in production to prevent accidental service deletion

## Additional Resources

- [Fastly Terraform Provider Docs](https://registry.terraform.io/providers/fastly/fastly/latest/docs)
- [Fastly VCL Documentation](https://www.fastly.com/documentation/guides/vcl/)
- [Tigris Object Storage Docs](https://fly.io/docs/tigris/)
- [OpenSpec Change Proposal](../openspec/changes/add-fastly-cdn-terraform/)
