# Upload certificate to RouterOS
resource "local_file" "server_key" {
  filename = "${path.module}/server.key"
  content  = acme_certificate.le_cert.private_key_pem
  file_permission = "0600"
}

resource "local_file" "server_cert" {
  filename = "${path.module}/server.crt"
  content  = "${acme_certificate.le_cert.certificate_pem}${acme_certificate.le_cert.issuer_pem}"
  file_permission = "0644"
}

locals {
  domain_name = "${var.subdomain}.${var.domain_prefix}.${var.cloudflare_zone_name}"
}

resource "routeros_file" "server_key" {
  name     = "${local.domain_name}-${var.certificate_file_names.key}.${var.certificate_suffix}"
  contents = acme_certificate.le_cert.private_key_pem
  depends_on = [local_file.server_key]
}

resource "routeros_file" "server_cert" {
  name     = "${local.domain_name}-${var.certificate_file_names.cert}.${var.certificate_suffix}"
  contents = "${acme_certificate.le_cert.certificate_pem}${acme_certificate.le_cert.issuer_pem}"
  depends_on = [local_file.server_cert]
}

resource "routeros_system_certificate" "server_cert" {
  name        = local.domain_name
  common_name = local.domain_name

  import {
    cert_file_name = routeros_file.server_cert.name
    key_file_name  = routeros_file.server_key.name
  }
  depends_on = [routeros_file.server_cert, routeros_file.server_key]
  lifecycle {
    replace_triggered_by = [
      acme_certificate.le_cert.certificate_pem
    ]
  }
}

# Configure services to use the certificate
resource "routeros_ip_service" "ssl_services" {
  for_each = toset(var.ssl_services)
  
  name        = each.key
  certificate = "${routeros_system_certificate.server_cert.name}-${var.certificate_file_names.cert}.${var.certificate_suffix}_0"
  depends_on  = [routeros_system_certificate.server_cert]
}

output "cert_serial_number_on_device" {
  value = routeros_system_certificate.server_cert.serial_number
}

output "domain_name" {
  value = local.domain_name
}

output "certificate_services" {
  value = [for service in var.ssl_services : "${service} using ${routeros_system_certificate.server_cert.name}-${var.certificate_file_names.cert}.${var.certificate_suffix}_0"]
}

# Cleanup local certificate files after successful upload
resource "null_resource" "cleanup_cert_files" {
  triggers = {
    cert_content = acme_certificate.le_cert.certificate_pem
  }

  provisioner "local-exec" {
    command = "rm -f ${path.module}/server.key ${path.module}/server.crt"
  }

  depends_on = [
    routeros_system_certificate.server_cert,
    local_file.server_key,
    local_file.server_cert
  ]
}
