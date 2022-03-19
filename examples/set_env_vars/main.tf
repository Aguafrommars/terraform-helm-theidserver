provider "helm" {
  kubernetes {
    config_path = "C:/Users/LefebvreO/.kube/config"
  }
}

module "theidserver" {
  source = "terraform-helm-theidserver"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"

  env_settings = {
    SendGridUser = "<SENDGRID_USER>"
    SendGridKey = "<SENDGRID_API_KEY>"
  }
}
