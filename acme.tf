# Create private key for ACME account
resource "tls_private_key" "acme_account_key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

# Register ACME account
resource "acme_registration" "account" {
  account_key_pem = tls_private_key.acme_account_key.private_key_pem
  email_address   = var.acme_email
}

# ACME Certificate
resource "acme_certificate" "le_cert" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = "${var.subdomain}.home.${var.cloudflare_zone_name}"
  key_type                 = "P384"
  min_days_remaining       = var.min_days_remaining
  revoke_certificate_on_destroy = true
  recursive_nameservers    = var.recursive_nameservers

  dns_challenge {
    provider = "cloudflare"
    config = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare_dns_api_token
      CLOUDFLARE_ZONE_API_TOKEN = var.cloudflare_zone_api_token
      CLOUDFLARE_ZONE_ID = var.cloudflare_zone_id
      CLOUDFLARE_ZONE = var.cloudflare_zone_name
      CLOUDFLARE_TTL = var.cloudflare_ttl
      CLOUDFLARE_PROPAGATION_TIMEOUT = var.cloudflare_propagation_timeout
      CLOUDFLARE_POLLING_INTERVAL = var.cloudflare_polling_interval
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
