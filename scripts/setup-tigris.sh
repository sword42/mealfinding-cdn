#!/bin/bash
# Creates Tigris bucket for Terraform state storage

set -euo pipefail

BUCKET_NAME="mealfinding-terraform-state"

# Use flyctl from common locations
if command -v flyctl &> /dev/null; then
    FLY_CMD="flyctl"
elif [ -f "$HOME/.fly/bin/flyctl" ]; then
    FLY_CMD="$HOME/.fly/bin/flyctl"
elif command -v fly &> /dev/null; then
    FLY_CMD="fly"
else
    echo "Error: flyctl not found. Please install: https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

echo "========================================="
echo "Tigris Bucket Setup for Terraform State"
echo "========================================="
echo ""
echo "Creating bucket: $BUCKET_NAME"
echo ""

# Create the bucket using Fly CLI
# This requires you to be logged into Fly (flyctl auth login)
$FLY_CMD storage create --org personal --name "$BUCKET_NAME"

echo ""
echo "========================================="
echo "Bucket created successfully!"
echo "========================================="
echo ""
echo "IMPORTANT: Save the credentials from above!"
echo ""
echo "You'll need to set these environment variables:"
echo ""
echo "  export AWS_ACCESS_KEY_ID=tid_xxxxx"
echo "  export AWS_SECRET_ACCESS_KEY=tsec_xxxxx"
echo "  export AWS_ENDPOINT_URL_S3=https://fly.storage.tigris.dev"
echo ""
echo "These credentials are also needed for Terraform:"
echo ""
echo "  export FASTLY_API_KEY=your-fastly-api-key"
echo ""
echo "Next steps:"
echo "  1. Copy the credentials shown above"
echo "  2. Set the environment variables in your shell"
echo "  3. Run 'cd terraform && terraform init'"
echo ""
