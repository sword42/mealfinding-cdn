# Terraform and Provider Configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = "~> 8.6"
    }
  }

  # Tigris S3-compatible backend for state storage
  # Initialize with: terraform init
  # Requires environment variables:
  #   - AWS_ACCESS_KEY_ID (tid_xxxxx)
  #   - AWS_SECRET_ACCESS_KEY (tsec_xxxxx)
  backend "s3" {
    bucket = "mealfinding-terraform-state"
    key    = "cdn/terraform.tfstate"
    region = "auto"

    endpoint = "https://fly.storage.tigris.dev"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

# Fastly provider - uses FASTLY_API_KEY environment variable
provider "fastly" {
  # API key is read from FASTLY_API_KEY environment variable
}
