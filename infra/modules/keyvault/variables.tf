variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_ip_address" {
  type = string
}

variable "virtual_machine_identity_principal_id" {
  type = string
}

variable "docker_container_app_id" {
  type = string
}

variable "docker_container_app_password" {
  type      = string
  sensitive = true
}
