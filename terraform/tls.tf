# TLS/SSL Certificate Configuration

# TLS Subscription for managed certificates via Let's Encrypt
resource "fastly_tls_subscription" "mealfinding" {
  domains = [
    var.domain_name,
    "www.${var.domain_name}",
    "api.${var.domain_name}"
  ]

  certificate_authority = "lets-encrypt"

  # Common name for the certificate
  common_name = var.domain_name

  # Depends on the service being created first
  depends_on = [fastly_service_vcl.mealfinding]
}

# Wait for TLS validation to complete
resource "fastly_tls_subscription_validation" "mealfinding" {
  subscription_id = fastly_tls_subscription.mealfinding.id
}
