# Setup Scripts

## setup-tigris.sh

Creates a Tigris bucket for Terraform state storage.

### Prerequisites

- Fly.io CLI installed and authenticated (`flyctl auth login`)

### Usage

```bash
./scripts/setup-tigris.sh
```

### Environment Variables

After running the script, you'll receive Tigris credentials. Set these environment variables:

```bash
# Tigris credentials (from setup-tigris.sh output)
export AWS_ACCESS_KEY_ID="tid_xxxxx"
export AWS_SECRET_ACCESS_KEY="tsec_xxxxx"
export AWS_ENDPOINT_URL_S3="https://fly.storage.tigris.dev"

# Fastly API key (create at https://manage.fastly.com/account/personal/tokens)
export FASTLY_API_KEY="your-fastly-api-key"
```

**Security Note**: Never commit these credentials to git. They are excluded via `.gitignore`.

### Next Steps

After setting environment variables:

```bash
cd terraform
terraform init
```
