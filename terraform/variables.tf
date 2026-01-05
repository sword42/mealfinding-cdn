# Terraform Variables

variable "service_name" {
  description = "Name of the Fastly service"
  type        = string
  default     = "mealfinding-production"
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "mealfinding.com"
}

variable "web_origin" {
  description = "Origin server for web frontend"
  type = object({
    address = string
    port    = number
  })
  default = {
    address = "mealfinding-web.fly.dev"
    port    = 443
  }
}

variable "api_origin" {
  description = "Origin server for API"
  type = object({
    address = string
    port    = number
  })
  default = {
    address = "mealfinding-api.fly.dev"
    port    = 443
  }
}

# Cache TTL configurations
variable "static_asset_ttl" {
  description = "TTL for static assets (JS, CSS, images) in seconds"
  type        = number
  default     = 86400 # 24 hours
}

variable "html_ttl" {
  description = "TTL for HTML pages (SSG content) in seconds"
  type        = number
  default     = 3600 # 1 hour
}

variable "api_default_ttl" {
  description = "Default TTL for API responses in seconds (0 = pass through)"
  type        = number
  default     = 0 # No caching by default for API
}

variable "force_destroy" {
  description = "Allow destroying the service even when active"
  type        = bool
  default     = false
}
