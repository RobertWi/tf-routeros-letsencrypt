terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "2.28.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    routeros = {
      source = "terraform-routeros/routeros"
      version = "1.69.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_zone_api_token
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "routeros" {
  hosturl = var.router_url
  username = var.router_user
  password = var.router_password
  insecure = true
}
