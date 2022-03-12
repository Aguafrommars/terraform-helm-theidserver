resource "tls_private_key" "ca_private_key" {
  algorithm   = "RSA"
}

resource "tls_private_key" "ssl_private_key" {
  algorithm   = "RSA"
}

resource "tls_private_key" "data_protection_private_key" {
  algorithm   = "RSA"
}

resource "tls_private_key" "signing_key_private_key" {
  algorithm   = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = fileexists("private_key.pem") ? "${file("private_key.pem")}" : "${tls_private_key.ca_private_key.private_key_pem}"

  is_ca_certificate = true

  subject {
    common_name  = "${var.ca_common_name}"
    organization = "${var.ca_organization}"
  }

  validity_period_hours = 26280

  allowed_uses = [
    "cert_signin",
    "client_auth",
    "server_auth"
  ]
}

resource "tls_cert_request" "cert_request" {
  key_algorithm   = "RSA"
  private_key_pem = fileexists("private_key.pem") ? "${file("private_key.pem")}" : "${tls_private_key.ssl_private_key.private_key_pem}"

  subject {
    common_name  = "${var.ssl_common_name}"
    organization = "${var.ssl_organization}"
  }

  dns_names = var.cert_dns_names
  uris = var.cert_uris
}

resource "tls_cert_request" "data_protection_cert_request" {
  key_algorithm   = "RSA"
  private_key_pem = fileexists("data_protection_private_key.pem") ? "${file("data_protection_private_key.pem")}" : "${tls_private_key.data_protection_private_key.private_key_pem}"

  subject {
    common_name  = "${var.ssl_common_name}"
    organization = "${var.ssl_organization}"
  }

  dns_names = var.cert_dns_names
  uris = var.cert_uris
}

resource "tls_cert_request" "signing_key_cert_request" {
  key_algorithm   = "RSA"
  private_key_pem = fileexists("signing_key_private_key.pem") ? "${file("signing_key_private_key.pem")}" : "${tls_private_key.signing_key_private_key.private_key_pem}"

  subject {
    common_name  = "${var.ssl_common_name}"
    organization = "${var.ssl_organization}"
  }

  dns_names = var.cert_dns_names
  uris = var.cert_uris
}

resource "tls_locally_signed_cert" "ssl" {
  cert_request_pem   = fileexists("cert_request.pem") ? "${file("cert_request.pem")}" : "${tls_cert_request.cert_request.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = fileexists("cert_request.pem") ? "${file("ca_private_key.pem")}" : "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = fileexists("ca_cert.pem") ? "${file("ca_cert.pem")}" : "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 365

  allowed_uses = [   
    "client_auth", 
    "server_auth"
  ]
}

resource "tls_locally_signed_cert" "data_protection" {
  cert_request_pem   = fileexists("data_protection_request.pem") ? "${file("data_protection_request.pem")}" : "${tls_cert_request.data_protection_cert_request.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = fileexists("cert_request.pem") ? "${file("ca_private_key.pem")}" : "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = fileexists("ca_cert.pem") ? "${file("ca_cert.pem")}" : "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 365

  allowed_uses = [   
    "digital_signature", 
    "key_enciphement",
    "data_enciphement"
  ]
}

resource "tls_locally_signed_cert" "signing_key" {
  cert_request_pem   = fileexists("signing_key_cert_request.pem") ? "${file("signing_key_cert_request.pem")}" : "${tls_cert_request.signing_key_cert_request.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = fileexists("cert_request.pem") ? "${file("ca_private_key.pem")}" : "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = fileexists("ca_cert.pem") ? "${file("ca_cert.pem")}" : "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 365

  allowed_uses = [   
    "digital_signature", 
    "key_enciphement",
    "data_enciphement"    
  ]
}