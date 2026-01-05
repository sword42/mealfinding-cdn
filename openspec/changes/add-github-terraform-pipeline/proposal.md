# Change: Add GitHub Actions Terraform Pipeline

## Why

The Terraform infrastructure currently requires manual CLI operations for deployment. This creates risk of inconsistent deployments and lacks visibility into infrastructure changes. A CI/CD pipeline provides automated validation, plan review, and controlled deployments with audit trails.

## What Changes

- Add GitHub Actions workflow for Terraform with three stages:
  - **Validate**: Format check and syntax validation
  - **Plan**: Generate execution plan, save as artifact, post to PR comments
  - **Apply**: Manual approval via GitHub Issue, then apply saved plan
- Introduce new `ci-cd` capability specification
- Require three GitHub secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `FASTLY_API_KEY`

## Impact

- Affected specs: New `ci-cd` capability (relates to `cdn-infrastructure`)
- Affected code: `.github/workflows/terraform.yml` (new file)
- Dependencies: `trstringer/manual-approval` GitHub Action for approval flow
