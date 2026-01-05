# Tasks: Add GitHub Actions Terraform Pipeline

## 1. Setup

- [ ] 1.1 Create `.github/workflows/` directory
- [ ] 1.2 Add required secrets to GitHub repository settings:
  - `AWS_ACCESS_KEY_ID` (Tigris access token)
  - `AWS_SECRET_ACCESS_KEY` (Tigris secret key)
  - `FASTLY_API_KEY` (Fastly API token)

## 2. Implementation

- [ ] 2.1 Create `.github/workflows/terraform.yml` workflow file
- [ ] 2.2 Implement `terraform-validate` job:
  - Checkout, setup Terraform 1.5.x
  - `terraform fmt -check -recursive`
  - `terraform init -backend=false`
  - `terraform validate`
  - Summary output to workflow summary
- [ ] 2.3 Implement `terraform-plan` job:
  - Depends on validate job
  - Configure Tigris and Fastly secrets as env vars
  - `terraform init` with backend
  - `terraform plan -out=tfplan`
  - Upload plan artifact (1-day retention)
  - Post plan as PR comment (conditional on PR event)
- [ ] 2.4 Implement `terraform-apply` job:
  - Depends on plan job
  - Conditional: only on push to main
  - `trstringer/manual-approval@v1` with approver: `sword`
  - Download plan artifact
  - `terraform apply tfplan`
- [ ] 2.5 Configure concurrency control:
  - Group by `terraform-${{ github.ref }}`
  - Cancel-in-progress for PRs only
- [ ] 2.6 Configure path filters for `terraform/**` and workflow file

## 3. Documentation

- [ ] 3.1 Update `terraform/README.md` with CI/CD pipeline documentation:
  - How to trigger deployments
  - How to approve applies
  - Required secrets setup

## 4. Testing

- [ ] 4.1 Create test PR with trivial terraform change (e.g., comment)
- [ ] 4.2 Verify validation stage runs and passes
- [ ] 4.3 Verify plan is posted as PR comment
- [ ] 4.4 Merge to main and verify approval issue is created
- [ ] 4.5 Test approval flow by commenting "approved"
- [ ] 4.6 Verify apply executes successfully
- [ ] 4.7 Test denial flow by commenting "denied" on a subsequent run
