# Basic usage

``` hcl
provider "helm" {
  kubernetes {
    config_path = "C:/Users/LefebvreO/.kube/config"
  }
}

module "theidserver" {
  source = "Aguafrommars/theidserver/helm"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"
}
```