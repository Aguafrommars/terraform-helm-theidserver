provider "helm" {
  kubernetes {
    config_path = "C:/Users/LefebvreO/.kube/config"
  }
}

resource "random_password" "mysql_password" {
  length           = 16
  special          = false
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = false
}

resource "random_password" "api_secret" {
  length           = 16
  special          = true
}

resource "helm_release" "theidserver" {
  name       = "theidserver"
  chart      = "C:\\Projects\\Perso\\helm\\charts\\theidserver"

  values = [
    "${file("theidserver-values.yaml")}"
  ]

  reuse_values = var.reuse_values
  recreate_pods = var.recreate_pods

  set_sensitive {
    name  = "ssl.ca.crt"
    value = fileexists("ca.pem") ? "${file("ca.pem")}" : "${base64encode(tls_self_signed_cert.ca.cert_pem)}"
  }

  set_sensitive {
    name  = "ssl.ca.key"
    value = fileexists("ca.key") ? "${file("ca.key")}" : "${base64encode(tls_private_key.ca_private_key.private_key_pem)}"
  }

  set_sensitive {
    name  = "ssl.crt"
    value = fileexists("ca.pem") ? "${file("ca.pem")}" : "${base64encode(tls_locally_signed_cert.ssl.cert_pem)}"
  }

  set_sensitive {
    name  = "ssl.key"
    value = fileexists("ssl.key") ? "${file("ssl.key")}" : "${base64encode(tls_private_key.ssl_private_key.private_key_pem)}"
  }

  set_sensitive {
    name  = "dataProtection.crt"
    value = fileexists("data_protection.pem") ? "${file("data_protection.pem")}" : "${base64encode(tls_locally_signed_cert.data_protection.cert_pem)}"
  }

  set_sensitive {
    name  = "dataProtection.key"
    value = fileexists("data_protection.key") ? "${file("data_protection.key")}" : "${base64encode(tls_private_key.data_protection_private_key.private_key_pem)}"
  }

  set_sensitive {
    name  = "signingKey.crt"
    value = fileexists("signing_key.pem") ? "${file("signing_key.pem")}" : "${base64encode(tls_locally_signed_cert.signing_key.cert_pem)}"
  }

  set_sensitive {
    name  = "signingKey.key"
    value = fileexists("signing_key.key") ? "${file("signing_key.key")}" : "${base64encode(tls_private_key.signing_key_private_key.private_key_pem)}"
  }

  set_sensitive {
    name = "mysql.auth.rootPassword"
    value = "${random_password.mysql_root_password.result}"
  }

  set_sensitive {
    name = "mysql.auth.password"
    value = "${random_password.mysql_password.result}"
  }

  set_sensitive {
    name = "appSettings.file.InitialData.Apis[0].ApiSecrets[0].Value"
    value = "${random_password.api_secret.result}"
  }

  set_sensitive {
    name = "appSettings.file.ApiAuthentication.ApiSecret"
    value = "${random_password.api_secret.result}"
  }
}
