# Main Fastly VCL Service Configuration

resource "fastly_service_vcl" "mealfinding" {
  name = var.service_name

  # ============================================
  # BACKENDS (Origin Servers)
  # ============================================

  # Web Frontend Backend (serves www and apex domain)
  backend {
    name                  = "web_origin"
    address               = var.web_origin.address
    port                  = var.web_origin.port
    use_ssl               = true
    ssl_cert_hostname     = var.web_origin.address
    ssl_sni_hostname      = var.web_origin.address
    ssl_check_cert        = true
    override_host         = var.web_origin.address
    connect_timeout       = 5000
    first_byte_timeout    = 60000
    between_bytes_timeout = 30000
    max_conn              = 200
    weight                = 100
    shield                = "iad-va-us" # Shield POP for origin protection
  }

  # API Backend
  backend {
    name                  = "api_origin"
    address               = var.api_origin.address
    port                  = var.api_origin.port
    use_ssl               = true
    ssl_cert_hostname     = var.api_origin.address
    ssl_sni_hostname      = var.api_origin.address
    ssl_check_cert        = true
    override_host         = var.api_origin.address
    connect_timeout       = 5000
    first_byte_timeout    = 60000
    between_bytes_timeout = 30000
    max_conn              = 200
    weight                = 100
    shield                = "iad-va-us"
  }

  # ============================================
  # CONDITIONS
  # ============================================

  # Condition: Request is for API subdomain
  condition {
    name      = "is_api_request"
    type      = "REQUEST"
    statement = "req.http.host == \"api.${var.domain_name}\""
    priority  = 10
  }

  # Condition: Request is for static assets
  condition {
    name      = "is_static_asset"
    type      = "REQUEST"
    statement = "req.url.ext ~ \"^(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|webp|avif)$\""
    priority  = 20
  }

  # Condition: Request is for HTML
  condition {
    name      = "is_html_request"
    type      = "REQUEST"
    statement = "req.url.ext == \"html\" || req.url.path ~ \"^/[^.]*$\""
    priority  = 30
  }

  # ============================================
  # CACHE SETTINGS
  # ============================================

  # Static assets - long cache TTL
  cache_setting {
    name            = "cache_static_assets"
    action          = "cache"
    ttl             = var.static_asset_ttl
    stale_ttl       = 86400 # Serve stale for 24h if origin is down
    cache_condition = "is_static_asset"
  }

  # HTML pages (SSG content) - moderate TTL
  cache_setting {
    name            = "cache_html_pages"
    action          = "cache"
    ttl             = var.html_ttl
    stale_ttl       = 3600
    cache_condition = "is_html_request"
  }

  # API requests - pass through (no caching)
  cache_setting {
    name            = "pass_api_requests"
    action          = "pass"
    cache_condition = "is_api_request"
  }

  # ============================================
  # REQUEST SETTINGS
  # ============================================

  request_setting {
    name      = "force_ssl"
    force_ssl = true
  }

  # ============================================
  # HEADERS - Security and Performance
  # ============================================

  # Security: Strict-Transport-Security
  header {
    name        = "add_hsts"
    action      = "set"
    type        = "response"
    destination = "http.Strict-Transport-Security"
    source      = "\"max-age=31536000; includeSubDomains; preload\""
    priority    = 100
  }

  # Security: X-Content-Type-Options
  header {
    name        = "add_xcto"
    action      = "set"
    type        = "response"
    destination = "http.X-Content-Type-Options"
    source      = "\"nosniff\""
    priority    = 100
  }

  # Security: X-Frame-Options
  header {
    name        = "add_xfo"
    action      = "set"
    type        = "response"
    destination = "http.X-Frame-Options"
    source      = "\"SAMEORIGIN\""
    priority    = 100
  }

  # Security: Referrer-Policy
  header {
    name        = "add_referrer_policy"
    action      = "set"
    type        = "response"
    destination = "http.Referrer-Policy"
    source      = "\"strict-origin-when-cross-origin\""
    priority    = 100
  }

  # Security: Content-Security-Policy (basic)
  header {
    name        = "add_csp"
    action      = "set"
    type        = "response"
    destination = "http.Content-Security-Policy"
    source      = "\"default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.mealfinding.com\""
    priority    = 100
  }

  # Performance: Remove server identification headers
  header {
    name        = "remove_x_powered_by"
    action      = "delete"
    type        = "response"
    destination = "http.X-Powered-By"
    priority    = 50
  }

  header {
    name        = "remove_server"
    action      = "delete"
    type        = "response"
    destination = "http.Server"
    priority    = 50
  }

  # ============================================
  # CUSTOM VCL
  # ============================================

  vcl {
    name    = "main"
    content = file("${path.module}/vcl/main.vcl")
    main    = true
  }

  # ============================================
  # GZIP COMPRESSION
  # ============================================

  gzip {
    name       = "gzip_standard"
    extensions = ["css", "js", "html", "eot", "ico", "otf", "ttf", "json", "svg", "xml", "txt"]
    content_types = [
      "text/html",
      "application/x-javascript",
      "text/css",
      "application/javascript",
      "text/javascript",
      "application/json",
      "application/vnd.ms-fontobject",
      "application/x-font-opentype",
      "application/x-font-truetype",
      "application/x-font-ttf",
      "application/xml",
      "font/eot",
      "font/opentype",
      "font/otf",
      "image/svg+xml",
      "image/vnd.microsoft.icon",
      "text/plain",
      "text/xml"
    ]
  }

  # ============================================
  # SERVICE SETTINGS
  # ============================================

  default_ttl        = 3600
  stale_if_error     = true
  stale_if_error_ttl = 86400

  # Enable HTTP/3
  http3 = true

  force_destroy = var.force_destroy

  # Activate new version immediately
  activate = true
}
