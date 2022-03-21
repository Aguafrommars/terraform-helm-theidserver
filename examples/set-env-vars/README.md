# Set env vars

This sample set SendGrid credentials from input through env vars.

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

  env_settings = {
    SendGridUser = var.sendgrid_user
    SendGridKey = var.sendgrid_api_key
  }
}
```