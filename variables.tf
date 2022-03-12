variable "ssl_common_name"{
  type = string
  description = "TheIdServer SSL common name"
  default = "theidserver"
}

variable "ssl_organization"{
  type = string
  description = "TheIdServer SSL organization"
  default = "TheIdServer"
}

variable "ca_common_name"{
  type = string
  description = "ca certificates common name"
  default = "aguafommmars CA"
}

variable "ca_organization"{
  type = string
  description = "ca certificates organization"
  default = "Agua from Mars"
}

variable "cert_dns_names" {
  type = list(string)
  description = "certificates request dns names list"
  default = [ "theidserver.com", "localhost", "localhost:5443" ]
}

variable "cert_uris" {
  type = list(string)
  description = "certificates request uri list"
  default = [ "127.0.0.1" ]
}

variable "kubernetes" {
  type = any
  description = "kubernetes configuration"
  default = {
    config_path = "~/.kube/config"
  }
}

variable "replicaCount" {
  type = number
  description = "replica count"
  default = 1
}

variable "reuse_values" {
  type = bool
  description = "reuse value for helm chart"
  default = true
}

variable "recreate_pods" {
  type = bool
  description = "recreate pods"
  default = true
}