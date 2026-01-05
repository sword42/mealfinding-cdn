# Domain Management using Fastly Domain v1 Resources
# Domains are managed separately from the service to use the new domain management API

resource "fastly_domain_v1" "apex" {
  service_id = fastly_service_vcl.mealfinding.id
  fqdn       = var.domain_name
}

resource "fastly_domain_v1" "www" {
  service_id = fastly_service_vcl.mealfinding.id
  fqdn       = "www.${var.domain_name}"
}

resource "fastly_domain_v1" "api" {
  service_id = fastly_service_vcl.mealfinding.id
  fqdn       = "api.${var.domain_name}"
}
