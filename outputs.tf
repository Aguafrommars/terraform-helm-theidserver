output "admin_name" {
  value = format("admin@%s", var.host)
  description = "The TheIdServer admin name"
}

output "admin_password" {
  value = random_password.admin_password
  description = "The TheIdServer admin password"
  sensitive   = true
}
