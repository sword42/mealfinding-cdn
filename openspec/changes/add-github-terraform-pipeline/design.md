# Design: GitHub Actions Terraform Pipeline

## Context

The mealfinding-cdn project uses Terraform to manage Fastly CDN infrastructure with state stored in Tigris S3-compatible storage. Currently, deployments require manual `terraform apply` commands with proper credentials configured locally. This approach lacks:
- Automated validation on code changes
- Visibility into planned changes during PR review
- Audit trail of who approved deployments
- Protection against accidental or concurrent applies

## Goals / Non-Goals

**Goals:**
- Automate Terraform validation on every PR and push
- Provide plan visibility in PR comments for review
- Require explicit manual approval before any apply
- Prevent concurrent Terraform operations
- Use saved plan artifacts for consistency between plan and apply

**Non-Goals:**
- Auto-apply on merge (explicitly avoided for safety)
- Multi-environment support (production only for now)
- Terraform workspace management
- Drift detection or scheduled applies

## Decisions

### Decision 1: Three-Stage Pipeline Architecture

**Choice:** Separate validate, plan, and apply into distinct jobs with dependencies.

**Rationale:**
- Clear separation of concerns
- Fail fast on validation errors before consuming API quota
- Plan job can complete even if apply is never triggered
- Each stage has distinct permission requirements

**Alternatives considered:**
- Single job with conditional steps: Simpler but less granular failure handling
- Separate workflows per stage: More complex to coordinate artifacts

### Decision 2: Manual Approval via GitHub Issues

**Choice:** Use `trstringer/manual-approval` action to create GitHub Issues for approval.

**Rationale:**
- No GitHub Enterprise required (unlike Environment protection rules)
- Creates visible audit trail in Issues
- Familiar GitHub-native experience
- Supports multiple approvers and minimum approval counts

**Alternatives considered:**
- GitHub Environments with required reviewers: Requires GitHub Pro/Enterprise for private repos
- Workflow dispatch with apply parameter: Less visible, no approval record
- External approval systems (Slack, etc.): Additional integration complexity

### Decision 3: Plan Artifact Strategy

**Choice:** Save binary `tfplan` file as artifact with 1-day retention.

**Rationale:**
- Ensures apply uses exact same plan that was reviewed
- Prevents drift between plan and apply
- 1-day retention balances storage cost vs. reasonable approval window

**Alternatives considered:**
- Re-plan on apply: Risk of applying different changes than reviewed
- Longer retention: Unnecessary storage cost, plans become stale anyway

### Decision 4: Concurrency Control

**Choice:** Use GitHub Actions `concurrency` with cancel-in-progress for PRs only.

**Rationale:**
- Prevents Terraform state corruption from parallel operations
- Fast feedback on PRs by cancelling superseded runs
- Never cancel main branch runs to protect in-progress applies

**Configuration:**
```yaml
concurrency:
  group: terraform-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

### Decision 5: Path Filtering

**Choice:** Only trigger on changes to `terraform/**` and `.github/workflows/terraform.yml`.

**Rationale:**
- Avoids unnecessary pipeline runs on unrelated changes
- Reduces API usage and runner time
- Still triggers on workflow file changes for self-testing

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| Plan artifact expires before approval | Apply job fails | 1-day retention is generous; re-run workflow if needed |
| State changes between plan and apply | Apply fails or unexpected changes | Concurrency control prevents parallel ops; re-plan if needed |
| Approval issue left open | Clutters issue tracker | Issues auto-close on workflow completion |
| Secrets exposed in logs | Security breach | GitHub automatically masks secrets; no echo commands |
| Manual approval bypassed | Unauthorized deployment | GitHub token permissions limit who can comment |

## Migration Plan

1. Add secrets to GitHub repository settings
2. Create workflow file on feature branch
3. Test with trivial terraform change PR
4. Merge to main and verify full flow
5. Document in terraform/README.md

No rollback needed - removing workflow file disables automation, manual CLI remains available.

## Open Questions

None - all design decisions resolved during analysis phase.
