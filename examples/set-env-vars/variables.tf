variable "kubeconfig_path" {
  type = string
  description = "Path to the .kube/config"
}


variable "sendgrid_user" {
  type = string
  description = "Your SendGrid user"
}

variable "sendgrid_api_key" {
  type = string
  description = "Your SendGrid API key"
}
