## ADDED Requirements

### Requirement: Subdomain-Based Routing

The system SHALL route requests to the appropriate backend based on the request hostname using VCL logic.

#### Scenario: API subdomain routing

- **WHEN** a request is received for `api.mealfinding.com`
- **THEN** the request is routed to the `api_origin` backend

#### Scenario: WWW subdomain routing

- **WHEN** a request is received for `www.mealfinding.com`
- **THEN** the request is routed to the `web_origin` backend

#### Scenario: Apex domain routing

- **WHEN** a request is received for `mealfinding.com` (apex)
- **THEN** the request is routed to the `web_origin` backend

### Requirement: HTTPS Enforcement

The system SHALL enforce HTTPS for all requests by redirecting HTTP to HTTPS.

#### Scenario: HTTP to HTTPS redirect

- **WHEN** a request is received over HTTP (non-SSL)
- **THEN** a 301 redirect is returned to the HTTPS version of the URL

### Requirement: Static Asset Caching

The system SHALL cache static assets with long TTLs to optimize delivery performance.

#### Scenario: Static asset cache hit

- **WHEN** a request is made for a static asset (JS, CSS, images, fonts, etc.)
- **THEN** the response is cached for 24 hours
- **AND** stale content may be served for up to 7 days if origin is unavailable

#### Scenario: Query string normalization

- **WHEN** a static asset request includes query parameters
- **THEN** query parameters are stripped from the cache key for better hit ratio

### Requirement: HTML Page Caching

The system SHALL cache SSG HTML pages with moderate TTLs to balance freshness and performance.

#### Scenario: HTML cache behavior

- **WHEN** a request is made for an HTML page
- **THEN** the response is cached for 1 hour
- **AND** stale content may be served for up to 1 hour during revalidation

### Requirement: API Pass-Through

The system SHALL NOT cache API responses by default, allowing the origin to control caching behavior.

#### Scenario: API request handling

- **WHEN** a request is made to `api.mealfinding.com`
- **THEN** the request is passed directly to the origin without edge caching
- **AND** origin Cache-Control headers are respected if present

#### Scenario: Authenticated API requests

- **WHEN** an API request includes an Authorization header
- **THEN** the request is always passed to the origin (never cached)

### Requirement: Security Headers

The system SHALL inject security headers into all responses to protect against common web vulnerabilities.

#### Scenario: HSTS header

- **WHEN** any response is returned
- **THEN** the `Strict-Transport-Security` header is set with `max-age=31536000; includeSubDomains; preload`

#### Scenario: Content security headers

- **WHEN** any response is returned
- **THEN** the following headers are set:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: SAMEORIGIN`
  - `Referrer-Policy: strict-origin-when-cross-origin`

#### Scenario: Server identification removal

- **WHEN** any response is returned
- **THEN** the `X-Powered-By` and `Server` headers are removed

### Requirement: Compression

The system SHALL compress text-based responses using gzip to reduce bandwidth.

#### Scenario: Gzip compression

- **WHEN** a response contains compressible content (HTML, CSS, JS, JSON, XML, SVG, etc.)
- **THEN** the response is gzip compressed at the edge

### Requirement: Custom Error Pages

The system SHALL serve user-friendly custom error pages for common error conditions.

#### Scenario: 503 service unavailable

- **WHEN** the origin returns a 503 error or is unreachable
- **THEN** a branded "We'll be right back" error page is served

#### Scenario: 404 not found

- **WHEN** a 404 error occurs
- **THEN** a branded "Page Not Found" error page is served with a link to the homepage

### Requirement: Cache Debugging

The system SHALL expose cache status information in response headers for debugging purposes.

#### Scenario: Cache status header

- **WHEN** any response is returned
- **THEN** the `X-Cache` header indicates HIT or MISS
- **AND** the `X-Cache-Hits` header shows the number of cache hits
