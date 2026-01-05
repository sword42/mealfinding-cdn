# ci-cd Specification

## Purpose

Automated CI/CD pipeline for Terraform infrastructure deployments via GitHub Actions.

## ADDED Requirements

### Requirement: Terraform Validation Stage

The system SHALL validate Terraform configuration on every pull request and push to main branch.

#### Scenario: Format validation

- **WHEN** a pull request or push targets the main branch with changes to `terraform/**`
- **THEN** the pipeline executes `terraform fmt -check -recursive`
- **AND** the pipeline fails if any files are incorrectly formatted

#### Scenario: Syntax validation

- **WHEN** format validation passes
- **THEN** the pipeline executes `terraform init -backend=false` and `terraform validate`
- **AND** the pipeline fails if syntax errors are detected

### Requirement: Terraform Plan Stage

The system SHALL generate and preserve Terraform execution plans for review before any infrastructure changes.

#### Scenario: Plan generation

- **WHEN** validation stage completes successfully
- **THEN** the pipeline executes `terraform plan -out=tfplan`
- **AND** the plan file is saved as a workflow artifact with 1-day retention

#### Scenario: PR plan comment

- **WHEN** the pipeline runs on a pull request
- **THEN** the plan output is posted as a comment on the pull request
- **AND** the comment includes a link to the workflow run

#### Scenario: Plan artifact preservation

- **WHEN** a plan is generated
- **THEN** both the binary plan file and human-readable plan text are uploaded as artifacts
- **AND** the apply stage uses the same plan file that was reviewed

### Requirement: Terraform Apply Stage

The system SHALL apply Terraform changes only after explicit manual approval and only on the main branch.

#### Scenario: Manual approval gate

- **WHEN** a push to main branch triggers the pipeline
- **AND** the plan stage completes successfully
- **THEN** a GitHub Issue is created requesting approval
- **AND** the apply stage waits for an approver to comment "approved"

#### Scenario: Apply execution

- **WHEN** manual approval is granted via the GitHub Issue
- **THEN** the pipeline downloads the saved plan artifact
- **AND** executes `terraform apply` using the saved plan file

#### Scenario: Apply denied

- **WHEN** an approver comments "denied" on the approval issue
- **THEN** the apply stage fails
- **AND** no infrastructure changes are made

#### Scenario: PR apply prevention

- **WHEN** the pipeline runs on a pull request
- **THEN** the apply stage is skipped entirely
- **AND** only validation and plan stages execute

### Requirement: Pipeline Concurrency Control

The system SHALL prevent concurrent Terraform operations to protect state integrity.

#### Scenario: Concurrent run prevention

- **WHEN** a Terraform pipeline is running for a given branch
- **AND** another pipeline is triggered for the same branch
- **THEN** only one pipeline executes at a time

#### Scenario: PR run cancellation

- **WHEN** a new commit is pushed to a pull request
- **AND** a pipeline is already running for that PR
- **THEN** the in-progress pipeline is cancelled
- **AND** the new pipeline starts

#### Scenario: Main branch protection

- **WHEN** a pipeline is running on the main branch
- **AND** another main branch pipeline is triggered
- **THEN** the new pipeline queues behind the running one
- **AND** in-progress runs are never cancelled

### Requirement: Secret Management

The system SHALL securely manage credentials required for Terraform operations.

#### Scenario: Required secrets

- **WHEN** the pipeline executes plan or apply stages
- **THEN** it requires `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `FASTLY_API_KEY` secrets
- **AND** secrets are never logged or exposed in outputs

#### Scenario: Validation without secrets

- **WHEN** the validation stage executes
- **THEN** it completes without requiring any secrets
- **AND** uses `terraform init -backend=false` to skip backend configuration
