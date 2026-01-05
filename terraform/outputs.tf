# Terraform Outputs

output "service_id" {
  description = "The Fastly service ID"
  value       = fastly_service_vcl.mealfinding.id
}

output "service_name" {
  description = "The Fastly service name"
  value       = fastly_service_vcl.mealfinding.name
}

output "active_version" {
  description = "The currently active version of the service"
  value       = fastly_service_vcl.mealfinding.active_version
}

output "domains" {
  description = "List of domains configured for this service"
  value = [
    var.domain_name,
    "www.${var.domain_name}",
    "api.${var.domain_name}"
  ]
}

output "fastly_cname" {
  description = "CNAME target for DNS configuration"
  value       = "${var.domain_name}.global.prod.fastly.net"
}

output "tls_subscription_id" {
  description = "TLS subscription ID"
  value       = fastly_tls_subscription.mealfinding.id
}

output "tls_state" {
  description = "Current state of the TLS subscription"
  value       = fastly_tls_subscription.mealfinding.state
}

output "tls_dns_challenges" {
  description = "DNS records required for TLS validation"
  value = {
    for challenge in fastly_tls_subscription.mealfinding.managed_dns_challenges :
    challenge.record_name => {
      type  = challenge.record_type
      value = challenge.record_value
    }
  }
}
