variable "acme_email" {
  description = "Email address for Let's Encrypt registration"
  type        = string
  sensitive   = true
}

variable "router_url" {
  description = "RouterOS API URL"
  type        = string
  sensitive   = true
}

variable "router_user" {
  description = "Username for MikroTik router API"
  type        = string
  sensitive   = true
}

variable "router_password" {
  description = "Password for MikroTik router API"
  type        = string
  sensitive   = true
}

variable "cloudflare_dns_api_token" {
  description = "Cloudflare DNS API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_api_token" {
  type = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudflare_zone_name" {
  description = "Cloudflare Zone Name (domain)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the certificate"
  type        = string
}

variable "email_address" {
  description = "Email address for Let's Encrypt registration"
  type        = string
}

variable "min_days_remaining" {
  description = "Minimum days remaining before certificate renewal"
  type        = number
  default     = 30
}

variable "recursive_nameservers" {
  description = "List of recursive nameservers to use for DNS resolution"
  type        = list(string)
  default     = ["1.1.1.1:53"]
}

variable "cloudflare_ttl" {
  description = "TTL for Cloudflare DNS records"
  type        = number
  default     = 120
}

variable "cloudflare_propagation_timeout" {
  description = "Timeout for DNS propagation"
  type        = number
  default     = 600
}

variable "cloudflare_polling_interval" {
  description = "Interval for checking DNS propagation"
  type        = number
  default     = 2
}

variable "domain_prefix" {
  description = "Domain prefix (e.g., 'home' in host.home.example.com)"
  type        = string
  default     = "home"
}

variable "certificate_suffix" {
  description = "Suffix for certificate files"
  type        = string
  default     = "pem"
}

variable "ssl_services" {
  description = "List of SSL services to configure with the certificate"
  type        = list(string)
  default     = ["www-ssl", "api-ssl"]
}

variable "certificate_file_names" {
  description = "Names for certificate files"
  type = object({
    cert = string
    key  = string
  })
  default = {
    cert = "fullchain"
    key  = "privkey"
  }
}
