variable "host" {
  type = string
  description = "The host"
}

variable "tls_issuer_name" {
  type = string
  description = "The name of the certificat issuer to use"
}

variable "tls_issuer_kind" {
  type = string
  description = "The kind of the certificat issuer to use (Issuer or ClusterIssuer)"
}

variable "chart" {
  type = string
  description = "(Optional) The Helm chart"
  default = "theidserver"
}

variable "chart_version" {
  type = string
  description = "(Optional) The Helm chart version"
  default = "4.8.0"
}

variable "namespace" {
  type = string
  description = "(Optional) Kubernetes namespace"
  default = "theidserver"
}

variable "create_namespace" {
  type = bool
  description = "(Optional) Creates the kubernetes namespace if not exists"
  default = true
}

variable "release_name" {
  type = string
  description = "(Optional) Helm release name"
  default = "theidserver"
}

variable "reuse_values" {
  type = bool
  description = "(Optional) reuse value for helm chart"
  default = false
}

variable "recreate_pods" {
  type = bool
  description = "(Optional) recreate pods"
  default = false
}

variable "wait" {
  type = bool
  description = "(Optional) Wait for helm release to be ready"
  default = true
}

variable "replica_count" {
  type = number
  description = "(Optional) Number of server pod"
  default = 3
}

variable "env_settings" {
  type = map(string)
  description = "Env var setting"
  sensitive = true
  default = {}
}

variable "override_settings" {
  type = any
  description = "Override helm settings"
  default = {}
}

variable "image" {
  type = map(string)
  description = "The docker image"
  default = {
  }
}
