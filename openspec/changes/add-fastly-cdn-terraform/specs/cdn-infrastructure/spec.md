## ADDED Requirements

### Requirement: Terraform State Management

The system SHALL store Terraform state in a Fly.io Tigris S3-compatible bucket to enable infrastructure versioning and collaboration.

#### Scenario: State backend initialization

- **WHEN** Terraform is initialized with valid Tigris credentials
- **THEN** state is stored in the `mealfinding-terraform-state` bucket
- **AND** state file is located at `cdn/terraform.tfstate`

#### Scenario: State locking

- **WHEN** multiple Terraform operations are attempted simultaneously
- **THEN** Tigris provides state locking to prevent corruption

### Requirement: Fastly CDN Service

The system SHALL provision a Fastly VCL service via Terraform to serve as the CDN and DDoS protection layer for the Mealfinding platform.

#### Scenario: Service creation

- **WHEN** `terraform apply` is executed with valid Fastly API credentials
- **THEN** a Fastly VCL service named `mealfinding-production` is created
- **AND** the service is activated automatically

#### Scenario: Service configuration

- **WHEN** the Fastly service is created
- **THEN** it SHALL include three domains: `mealfinding.com`, `www.mealfinding.com`, `api.mealfinding.com`
- **AND** it SHALL include two backends: `web_origin` and `api_origin`
- **AND** HTTP/3 SHALL be enabled

### Requirement: Origin Backend Configuration

The system SHALL configure origin backends with SSL, health checks, and shielding for optimal performance and reliability.

#### Scenario: Web origin backend

- **WHEN** requests target `mealfinding.com` or `www.mealfinding.com`
- **THEN** traffic is routed to `mealfinding.fly.dev` via HTTPS on port 443
- **AND** origin shielding is enabled at POP `iad-va-us`

#### Scenario: API origin backend

- **WHEN** requests target `api.mealfinding.com`
- **THEN** traffic is routed to `mealfinding-api.fly.dev` via HTTPS on port 443
- **AND** origin shielding is enabled at POP `iad-va-us`

### Requirement: TLS Certificate Management

The system SHALL provision and manage TLS certificates via Let's Encrypt for all configured domains.

#### Scenario: Certificate provisioning

- **WHEN** the TLS subscription is created
- **THEN** Terraform outputs DNS challenge records for domain validation
- **AND** certificates are issued for all three domains after DNS validation

#### Scenario: Certificate renewal

- **WHEN** certificates approach expiration
- **THEN** Fastly automatically renews them via Let's Encrypt

### Requirement: Setup Automation

The system SHALL provide scripts and documentation to automate initial setup tasks.

#### Scenario: Tigris bucket creation

- **WHEN** `scripts/setup-tigris.sh` is executed
- **THEN** a Tigris bucket named `mealfinding-terraform-state` is created
- **AND** access credentials are output for user configuration

#### Scenario: Environment variable configuration

- **WHEN** setting up the Terraform environment
- **THEN** users configure `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `FASTLY_API_KEY` via environment variables
