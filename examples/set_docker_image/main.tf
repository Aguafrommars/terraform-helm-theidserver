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

  image = {
    repository = "aguacongas/theidserver.duende"
    pullPolicy = "Always"
    tag = "next"
  }
}
