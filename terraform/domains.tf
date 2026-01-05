# Domain Management using Fastly Domain v1 Resources
# Domains are managed separately from the service to use the new domain management API

resource "fastly_domain_v1" "apex" {
  service_id = fastly_service_vcl.mealfinding.id
  name       = var.domain_name
  comment    = "Apex domain"
}

resource "fastly_domain_v1" "www" {
  service_id = fastly_service_vcl.mealfinding.id
  name       = "www.${var.domain_name}"
  comment    = "Primary www subdomain for web frontend"
}

resource "fastly_domain_v1" "api" {
  service_id = fastly_service_vcl.mealfinding.id
  name       = "api.${var.domain_name}"
  comment    = "API subdomain"
}
