resource "random_password" "mysql_password" {
  length           = 16
  special          = false
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = false
}

resource "random_password" "mysql_replication_password" {
  length           = 16
  special          = true
}

resource "random_password" "api_secret" {
  length           = 16
  special          = true
}

resource "random_password" "redis_password" {
  length           = 16
  special          = true
}

resource "random_password" "public_server_secret" {
  length           = 16
  special          = true
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  min_numeric = 1
  min_special = 1
  min_upper = 1
}

locals {
  settings = {
    image = var.image
    service = {
      ports = {
        https = 443
      }
    }    
    appSettings = {
      env = var.env_settings
      file = {
        ApiAuthentication = {
          Authority = format("https://www.%s", var.host)
          ApiSecret = "${random_password.api_secret.result}"
        }
        EmailApiAuthentication = {
          Authority = format("https://www.%s", var.host)
          ApiUrl = format("https://www.%s/api/email", var.host)
          ClientSecret = "${random_password.public_server_secret.result}"
        }
        BackchannelAuthenticationUserNotificationServiceOptions = {
          Authority = format("https://www.%s", var.host)
          ApiUrl = format("https://www.%s/api/email", var.host)
          ClientSecret = "${random_password.public_server_secret.result}"
        }
        InitialData = {
          Clients = [
            {
              ClientId = "theidserveradmin"
              ClientName = "TheIdServer admin SPA Client"
              ClientUri = "https://localhost:{{ .Values.service.ports.https }}"
              ClientClaimsPrefix = null
              AllowedGrantTypes = [ "authorization_code" ]
              RequirePkce = true
              RequireClientSecret = false
              BackChannelLogoutSessionRequired = false
              FrontChannelLogoutSessionRequired = false          
              ClientUri = format("https://www.%s", var.host)
              AllowedCorsOrigins = [
                format("https://www.%s", var.host)
              ]
              RedirectUris = [
                format("https://www.%s/authentication/login-callback", var.host)
              ]
              PostLogoutRedirectUris = [
                format("https://www.%s/authentication/logout-callback", var.host)
              ]
              AllowedScopes = [ "openid", "profile", "theidserveradminapi" ]
              AccessTokenType = "Reference"
            },
            { 
              ClientId = "public-server"
              ClientName = "Public server Credentials Client"
              ClientClaimsPrefix = null
              AllowedGrantTypes = [ "client_credentials" ]
              Claims = [
                {
                  Type = "role"
                  Value = "Is4-Writer"
                },
                {
                  Type = "role"
                  Value = "Is4-Reader"        
                }
              ]
              BackChannelLogoutSessionRequired = false
              FrontChannelLogoutSessionRequired = false
              AllowedScopes = [ "openid", "profile", "theidserveradminapi" ]
              AccessTokenType = "Reference"
              ClientSecrets = [{
                Type = "SharedSecret"
                Value = "${random_password.public_server_secret.result}"
              }]
            },
            {
              ClientId = "theidserver-swagger"
              ClientName = "TheIdServer Swagger UI"
              ClientClaimsPrefix = null
              AllowedGrantTypes = [ "implicit" ]
              AllowAccessTokensViaBrowser = true
              RequireClientSecret = false
              BackChannelLogoutSessionRequired = false
              FrontChannelLogoutSessionRequired = false
              AllowedCorsOrigins = [
                format("https://www.%s", var.host)
              ]
              RedirectUris = [
                format("https://www.%s/authentication/login-callback", var.host)
              ]
            }
          ]
          Apis = [
            {
              Name = "theidserveradminapi"
              DisplayName = "TheIdServer admin API"
              UserClaims = [ "name", "role" ]
              Scopes = [ "theidserveradminapi", "theidservertokenapi" ]
              ApiSecrets = [{
                Type = "SharedSecret"
                Value = "${random_password.api_secret.result}"
              }]
            }
          ]
          Users = [
            {
              UserName = "${format("admin@%s", var.host)}"
              Email = "${format("admin@%s", var.host)}"
              EmailConfirmed = true
              Roles = [
                "Is4-Writer",
                "Is4-Reader"
              ]
              Claims = [
                {
                  ClaimType = "name"
                  ClaimValue = "TheIdServer Admin"
                },
                {
                  ClaimType = "given_name"
                  ClaimValue = "Admin"
                },
                {
                  ClaimType = "nickname"
                  ClaimValue = "Admin"
                }
              ]
            }
          ]
        }
      }
    }
    adminSettings = {
      apiBaseUrl = format("https://www.%s/api", var.host)
      settingsOptions = {
        apiUrl = format("https://www.%s/api/api/configuration", var.host)
      }
      providerOptions = {
        authority = format("https://www.%s", var.host)
        postLogoutRedirectUri = format("https://www.%s/authentication/logout-callback", var.host)
        redirectUri = format("https://www.%s/authentication/login-callback", var.host)
      }
      welcomeContenUrl = format("https://www.%s/api/welcomefragment", var.host)
    }
    replicaCount = var.replica_count
    ingress = {
      enabled = true
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "cert-manager.io/cluster-issuer" = "letsencrypt"
      }
      tls = {
        hosts = [
          "${format("www.%s", var.host)}"
        ]
      }
      hosts = [
        {
          host = "${format("www.%s", var.host)}" 
        }            
      ]
    }
    ssl = {
      create = false
      ca = {
        create = false
        trust = false
      }
      issuer = {
        enabled = true
        ref = var.tls_issuer_name
        kind = var.tls_issuer_kind
      }
    }
    dataProtection = {
      create = false
      crt = "${base64encode(tls_locally_signed_cert.data_protection.cert_pem)}"
      key = "${base64encode(tls_private_key.data_protection_private_key.private_key_pem)}"
    }
    signingKey = {
      create = false
      crt = "${base64encode(tls_locally_signed_cert.signing_key.cert_pem)}"
      key = "${base64encode(tls_private_key.signing_key_private_key.private_key_pem)}"
    }
    mysql = {
      architecture = "replication"
      auth = {
        username = "theidserver"
        database = "theidserver"
        replicationUser = "theidserverReplication"    
        rootPassword = "${random_password.mysql_root_password.result}"
        password = "${random_password.mysql_password.result}"
        replicationPassword = "${random_password.mysql_replication_password.result}"
      }
    }
    redis = {
      replica = {
        replicaCount = 1
      }
      auth = {
        password = "${random_password.redis_password.result}"
      }
    }
    seq = {
      ingress = {
        annotations = {
          "kubernetes.io/ingress.class" = "nginx"
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          "cert-manager.io/cluster-issuer" = "letsencrypt"
        }
        tls = [{
          hosts = [
            "${format("seq.%s", var.host)}"
          ]
          secretName = "${format("%s-seq", var.release_name)}"
        }]
      }
      ui = {
        ingress = {
          enabled = true
          path = "/"
          hosts = [
            "${format("seq.%s", var.host)}"
          ]
        }
      }
    }
  }
}

resource "helm_release" "theidserver" {
  name       = var.release_name
  repository = "https://aguafrommars.github.io/helm"
  chart      = var.chart
  version    = var.chart_version
  namespace  = var.namespace
  create_namespace = var.create_namespace
  
  values = [
    yamlencode(local.settings),
    yamlencode(var.override_settings)
  ]

  reuse_values = var.reuse_values
  recreate_pods = var.recreate_pods
  wait = var.wait

  set_sensitive {
    name = "appSettings.env.InitialData__Users__0__Password"
    value = random_password.admin_password.result
  }
}
