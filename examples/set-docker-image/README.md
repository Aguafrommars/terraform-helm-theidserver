# Set docker image

This sample use the lastest built Duende version.

``` hcl
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

module "theidserver" {
  source = "Aguafrommars/theidserver/helm"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"

  image = {
    repository = "aguacongas/theidserver.duende"
    pullPolicy = "Always"
    tag = "next"
  }
}
```