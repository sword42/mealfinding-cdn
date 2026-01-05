## Context

This is a greenfield CDN infrastructure setup for the Mealfinding platform. The system will use Fastly as the CDN/edge provider, with fly.io as the origin server platform. Terraform will manage the infrastructure configuration with state stored in Fly.io Tigris (S3-compatible object storage).

**Stakeholders**: DevOps, Frontend (AstroJS), Backend (REST API)

**Constraints**:
- Single production environment (no staging CDN)
- Must support apex domain (mealfinding.com) and subdomains (www, api)
- Origins are already deployed on fly.io
- Credentials managed via environment variables (no secrets in repo)

## Goals / Non-Goals

**Goals**:
- Infrastructure-as-code CDN configuration via Terraform
- Optimized caching for AstroJS SSG content and static assets
- API traffic routed without caching (respects origin Cache-Control)
- Modern security headers enforced at edge
- Automated TLS certificate management via Let's Encrypt
- Clear documentation for setup and ongoing management

**Non-Goals**:
- Multi-environment setup (staging/dev CDN) - out of scope for initial implementation
- WAF rules or rate limiting - future enhancement
- Edge compute (Compute@Edge) - not needed initially
- Geographic routing - single origin per subdomain is sufficient

## Decisions

### Decision 1: Terraform State Backend - Tigris (S3-compatible)

**What**: Store Terraform state in Fly.io Tigris bucket

**Why**:
- Already using fly.io for origin servers, keeps infrastructure in one ecosystem
- S3-compatible API works with standard Terraform S3 backend
- No additional vendor (vs Terraform Cloud, AWS S3)

**Alternatives considered**:
- Local state: Simple but no collaboration, no locking
- Terraform Cloud: Extra vendor, overkill for single-person team
- AWS S3: Adds AWS dependency when already using fly.io

### Decision 2: Single Fastly VCL Service (not Compute@Edge)

**What**: Use traditional VCL-based Fastly service

**Why**:
- VCL is mature, well-documented, sufficient for routing/caching needs
- Lower complexity than Compute@Edge
- No custom edge logic required beyond routing and caching

**Alternatives considered**:
- Compute@Edge: More powerful but unnecessary complexity
- Separate services per subdomain: Would complicate TLS and increase costs

### Decision 3: Subdomain Routing via VCL

**What**: Single service handles all subdomains, VCL routes to correct backend

**Why**:
- All domains share one TLS subscription
- Centralized configuration
- Simpler than multiple Fastly services

**Implementation**: VCL `vcl_recv` checks `req.http.host` and sets `req.backend` accordingly

### Decision 4: Caching Strategy by Content Type

| Content | TTL | Stale-While-Revalidate | Rationale |
|---------|-----|------------------------|-----------|
| Static assets (JS/CSS/images) | 24h | 7 days | Immutable with cache-busting hashes |
| HTML (SSG) | 1h | 1h | Balance freshness vs performance |
| API | Pass-through | N/A | Dynamic content, respect origin headers |

### Decision 5: Origin Shielding

**What**: Enable shield POP at `iad-va-us` (Ashburn, Virginia)

**Why**:
- Consolidates origin requests through single POP
- Improves cache hit ratio
- Reduces load on fly.io origins

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Tigris S3 compatibility issues | Use documented Terraform backend config with required skip flags |
| TLS validation delays | Document DNS setup clearly, provide troubleshooting steps |
| VCL complexity growth | Keep VCL minimal, avoid edge logic creep |
| Single environment limits testing | Accept for MVP, add staging CDN if needed later |

## Migration Plan

This is a greenfield setup - no migration required. Deployment steps:

1. Create Tigris bucket for state storage
2. Apply Terraform to create Fastly service (inactive)
3. Configure DNS CNAME records
4. Complete TLS validation
5. Verify traffic flows correctly
6. Monitor for issues

**Rollback**: DNS can be pointed directly to fly.io origins if CDN issues arise.

## Open Questions

None - all requirements clarified during planning phase.
