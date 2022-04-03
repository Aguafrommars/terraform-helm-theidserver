# TheidServer Helm Terraform module

This module create a [TheIdServer](https://github.com/Aguafrommars/TheIdServer) cluster using the [TheIdServer helm chart](https://artifacthub.io/packages/helm/aguafrommars/theidserver) with its MySql DB, Redis cluster and [Seq](https://datalust.co/) server.

## Prerequises

- DNS record pointing to [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) public IP.
- [cert-manager](https://github.com/cert-manager/cert-manager)
- A certificate issuer

You can follow the [Create an HTTPS ingress controller on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-tls?tabs=azure-cli#add-an-a-record-to-your-dns-zone) to install this prerequise on your kubernetes cluster.

## Usage

The module setup ingresses for [TheIdServer](https://github.com/Aguafrommars/TheIdServer) and [Seq](https://datalust.co/) using the **host** input variable.

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
}
```

This will setup [TheIdServer](https://github.com/Aguafrommars/TheIdServer) on **https://www.theidserver.com** with the admin user **admin@theidserver.com** and its [Seq](https://datalust.co/) server on **https://seq.theidserver.com**.  
By default resouces are created in the *theidserver* namespace.

> We recommande to protect the Seq server with a user/pwd.

### Docker image

By default the [TheIdServer helm chart](https://artifacthub.io/packages/helm/aguafrommars/theidserver) install the [IdentityServer4](https://github.com/Aguafrommars/TheIdServer/blob/master/src/Aguacongas.TheIdServer.IS4/README.md) version.  
If you prefer to use the [Duende IdentityServer](https://github.com/Aguafrommars/TheIdServer/blob/master/src/Aguacongas.TheIdServer.Duende/README.md) version configure the **image** input to override the default docker image configuration.

``` hcl
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

> For a commercial use of [Duende IdentityServer](https://duendesoftware.com/products/identityserver) you need to [acquire a license](https://duendesoftware.com/products/identityserver#pricing).  

### Initial admin user password

The initial admin user passowrd is store in the configMap <release_name>-config at **InitialData__Users__0__Password** key.

``` bash
❯ kubectl get configMap theidserver-config -n theidserver -o jsonpath="{.data['InitialData__Users__0__Password']}"
SE!OfFGOm}(5v3wF
```

> The admin user is stored if not exists, we recommande to change its password at 1st login or register a new one and disable this one. Don't delete it or it will be recreated.

### Email server configuration

[TheIdServer](https://github.com/Aguafrommars/TheIdServer) needs to send email to verify users emails or for CIBA. The default Email service implementation use [SendGrid](https://sendgrid.com/) and read user and API key from configuration.  
The **env_settings** input can be use to pass environments variables to containers, so we can ovveride the configuration using environment variables. 

``` hcl
module "theidserver" {
  source = "Aguafrommars/theidserver/helm"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"

  env_settings = {
    SendGridUser = "<SENDGRID_USER>"
    SendGridKey = "<SENDGRID_API_KEY>"
  }
}
```
This sample setup [SendGrid](https://sendgrid.com/) environment variables used by [TheIdServer](https://github.com/Aguafrommars/TheIdServer).

If you want to use your Email sender, you need to implement a web api and setup its url. [Read the doc](https://github.com/Aguafrommars/TheIdServer/blob/master/src/Aguacongas.TheIdServer.Duende/README.md#use-your-api). 

``` hcl
module "theidserver" {
  source = "Aguafrommars/theidserver/helm"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"

  env_settings = {
    EmailApiAuthentication__ApiUrl = "<YOUR_EMAIL_SENDER_WEB_API>"
  }
}
```
This sampel setup the Email Sender url using environment variable.


### Override config

You can use the **override_settings** input to override the [TheIdServer helm chart](https://artifacthub.io/packages/helm/aguafrommars/theidserver).

``` hcl
module "theidserver" {
  source = "Aguafrommars/theidserver/helm"

  host = "theidserver.com"
  tls_issuer_name = "letsencrypt"
  tls_issuer_kind = "ClusterIssuer"

  override_settings = {
    appSettings = {
      file = {
        EmailApiAuthentication = {
          ApiUrl = "<YOUR_EMAIL_SENDER_WEB_API>"
        }
      }
    }
  }
}
```
This sample setup the Email Sender url using the appsettings.json file.

## Inputs

|Name|Description|Type|Default|  
|----|-----------|----|-------|  
|host|The host|string||
|tls_issuer_name|The name of the certificat issuer to use|string||
|tls_issuer_kind|The kind of the certificat issuer to use (Issuer or ClusterIssuer)|string||
|chart|(Optional) The Helm chart|string|"theidserver"|
|chart_version|(Optional) The Helm chart version|string|"4.7.0"|
|namespace|(Optional) Kubernetes namespace|string|"theidserver"|
|create_namespace|(Optional) Creates the kubernetes namespace if not exists|bool|true|
|release_name|(Optional) Helm release name|string|"theidserver"|
|reuse_values|(Optional) reuse value for helm chart|bool|false|
|recreate_pods|(Optional) recreate pods|bool|false|
|wait|(Optional) Wait for helm release to be ready|bool|true|
|replica_count|(Optional) Number of server pod|number|3|
|env_settings|(Optional) Env var settings|map(string)|{}|
|override_settings|(Optional) Override helm chart settings|any|{}|
|image|(Optional) Override Helm chart image|map(string)|{}|

## Outputs

|Name|Description|Type|Sensitive|  
|----|-----------|----|---------|  
|admin_name|The generated admin user name|string|false|
|admin_password|The generated admin user password|string|true|

## Upgrading from 1.0.x to 2.0.0

Stores protections keys duration was not long enough in version 1.0.x. since version 2.0.0 the duration 1000 years but to upgrade from 1.0.x you must save stores protection keys in *.pem* files at your terraform root or the server will not be able to read your dataprotection keys and signing keys any more :

```bash
kubectl get secrets theidserver-certs -n theidserver -o jsonpath="{.data['dataProtection\.crt']}" | base64 -d >> data_protection.pem
kubectl get secrets theidserver-certs -n theidserver -o jsonpath="{.data['dataProtection\.key']}" | base64 -d >> data_protection_private_key.pem
kubectl get secrets theidserver-certs -n theidserver -o jsonpath="{.data['signingKey\.crt']}" | base64 -d >> signing_key.pem
kubectl get secrets theidserver-certs -n theidserver -o jsonpath="{.data['signingKey\.key']}" | base64 -d >> signing_key_private_key.pem
```

The version 2.0.0 and above check if those files exists and use them instead of generated certificates.
