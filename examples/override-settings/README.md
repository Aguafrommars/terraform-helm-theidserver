# Override settings

This sample override the Email sender API url with the url passed in input.

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

  override_settings = {
    appSettings = {
      file = {
        EmailApiAuthentication = {
          ApiUrl = var.api_url
        }
      }
    }
  }
}
```