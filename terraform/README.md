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

## CI/CD Pipeline

### Overview

This project uses GitHub Actions to automatically validate, plan, and apply Terraform changes. The pipeline ensures safe infrastructure deployments with automated validation and manual approval gates.

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Terraform Pipeline                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ├─ Triggers:
                              │  • Push to main (terraform/**)
                              │  • Pull requests (terraform/**)
                              │
           ┌──────────────────┴──────────────────┐
           │                                     │
    ┌──────▼──────┐                    ┌────────▼────────┐
    │  VALIDATE   │                    │   VALIDATE      │
    │  (no secrets)│                    │   (no secrets)  │
    └──────┬──────┘                    └────────┬────────┘
           │                                     │
    ┌──────▼──────┐                    ┌────────▼────────┐
    │    PLAN     │                    │     PLAN        │
    │  (w/secrets)│                    │   (w/secrets)   │
    └──────┬──────┘                    └────────┬────────┘
           │                                     │
           │                              Post plan as
    ┌──────▼──────┐                      PR comment
    │   MANUAL    │                             │
    │  APPROVAL   │◄────────────────────────────┘
    │  (Issue)    │                       (PR: skip apply)
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │    APPLY    │
    │ (main only) │
    └─────────────┘
```

### How to Trigger Deployments

#### Automatic Triggers

The pipeline runs automatically when:

1. **Pull Requests** are opened/updated with changes to:
   - `terraform/**` (any Terraform file)
   - `.github/workflows/terraform.yml` (the workflow itself)

2. **Pushes to main** with changes to the same paths

#### What Runs Where

| Event | Validate | Plan | PR Comment | Apply |
|-------|----------|------|------------|-------|
| Pull Request | ✅ | ✅ | ✅ | ❌ (skipped) |
| Push to main | ✅ | ✅ | ❌ | ✅ (with approval) |

### Deployment Workflow

#### 1. Create a Pull Request

```bash
# Create feature branch
git checkout -b feat/update-cache-ttl

# Make changes to Terraform files
vim terraform/variables.tf

# Commit and push
git add terraform/
git commit -m "Update static asset cache TTL to 48 hours"
git push -u origin feat/update-cache-ttl
```

#### 2. Review the Plan

The pipeline will:
1. ✅ Validate formatting and syntax
2. 📋 Generate a Terraform plan
3. 💬 Post the plan as a PR comment

Review the plan in the PR comment to understand what will change.

#### 3. Merge to Main

Once the PR is approved and merged:
1. The pipeline runs again on `main`
2. Validation and planning stages complete
3. **An approval issue is automatically created**

#### 4. Approve the Deployment

**IMPORTANT**: Deployments to production require manual approval.

1. Go to the **Issues** tab in GitHub
2. Find the issue titled: **"Terraform Apply Approval Required"**
3. Review the plan in the workflow artifacts:
   - Click the workflow run link in the issue
   - Download the `tfplan` artifact
   - Review `tfplan.txt` to see exactly what will change
4. Comment on the issue:
   - **`approved`** - to proceed with the deployment
   - **`denied`** - to cancel the deployment

**Example approval comment:**
```
approved
```

**⚠️ Warning**: Typing `approved` will immediately trigger infrastructure changes. Double-check the plan first!

#### 5. Deployment Executes

After approval:
1. The pipeline downloads the saved plan
2. Runs `terraform apply` using the exact plan that was reviewed
3. Posts a summary of the results

### Required Secrets Setup

The pipeline requires three GitHub secrets. **These must be configured before the first deployment.**

#### Adding Secrets to GitHub

1. Go to: **Settings → Secrets and variables → Actions**
2. Click **"New repository secret"**
3. Add each of the following:

| Secret Name | Description | Format |
|-------------|-------------|--------|
| `AWS_ACCESS_KEY_ID` | Tigris access token | `tid_xxxxxxxxxxxxxxxxxxxxx` |
| `AWS_SECRET_ACCESS_KEY` | Tigris secret key | `tsec_xxxxxxxxxxxxxxxxxxxxx` |
| `FASTLY_API_KEY` | Fastly API token | Standard Fastly API key format |

#### Getting the Credentials

**Tigris credentials:**
```bash
./scripts/setup-tigris.sh
```
This outputs the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

**Fastly API key:**
- Create at: https://manage.fastly.com/account/personal/tokens
- Required scope: `global` or `global:read global:write`

**Security Note**: Secrets are masked in workflow logs and never exposed in plan outputs.

### Pipeline Concurrency Controls

The pipeline includes safety mechanisms to prevent state corruption:

#### For Pull Requests
- **New commits cancel previous runs** for fast feedback
- Multiple PRs can run simultaneously (different branches)

#### For Main Branch
- **Only one deployment runs at a time**
- Additional deployments queue (FIFO)
- In-progress deployments are **never cancelled**

### Viewing Pipeline Status

#### In Pull Requests
- ✅ Status checks show validate/plan results
- 💬 Plan output posted as a comment
- Workflow run link in PR checks

#### In GitHub Actions Tab
- View all workflow runs
- Download plan artifacts
- Review logs for debugging

### Manual Terraform Operations

You can still run Terraform locally for testing:

```bash
# Local plan (won't trigger CI/CD)
cd terraform
terraform plan

# Local apply (not recommended - use CI/CD instead)
terraform apply
```

**Best Practice**: Use the CI/CD pipeline for all production changes to maintain an audit trail and ensure peer review.

### Troubleshooting CI/CD

#### Pipeline fails at validation stage

**Symptoms**: Format check or validate fails

**Solutions**:
```bash
# Fix formatting
cd terraform
terraform fmt -recursive

# Validate syntax
terraform validate

# Commit fixes
git add .
git commit -m "Fix terraform formatting"
git push
```

#### Pipeline fails at plan stage

**Symptoms**: Plan fails with authentication or provider errors

**Solutions**:
1. Verify GitHub secrets are configured correctly
2. Check secret names match exactly: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `FASTLY_API_KEY`
3. Ensure Tigris credentials haven't expired
4. Review workflow logs in the Actions tab

#### Approval issue not created

**Symptoms**: Pipeline reaches apply stage but no approval issue appears

**Solutions**:
1. Check the Actions tab for the workflow run
2. Verify the run is on the `main` branch (apply only runs on main)
3. Check GitHub repository settings allow issue creation
4. Review workflow logs for errors

#### Apply hangs waiting for approval

**Symptoms**: Pipeline waiting indefinitely at approval step

**Solutions**:
1. Find the approval issue in the Issues tab
2. Comment `approved` or `denied`
3. If the issue is closed accidentally, cancel the workflow run and push a new commit

#### Plan differs between PR and main

**Symptoms**: Plan in PR comment doesn't match what runs on main

**Solutions**:
1. This is expected if infrastructure changed between PR creation and merge
2. Review the approval issue's plan artifact before approving
3. Cancel and create a new PR with updated changes if needed

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

- `mealfinding.com` (apex) → `mealfinding.fly.dev`
- `www.mealfinding.com` → `mealfinding.fly.dev`
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
