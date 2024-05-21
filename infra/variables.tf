### General ###
variable "location" {
  type = string
}
variable "admin_ip_address" {
  type = string
}

### MSSQL ###
variable "mssql_public_network_access_enabled" {
  type = string
}

variable "mssql_sku" {
  type = string
}

variable "mssql_max_size_gb" {
  type = number
}

### App Service ###
variable "enable_webapp" {
  type = bool
}

variable "webapp_plan_sku_name" {
  type = string
}

### Virtual Machine ###
variable "enable_virtual_machine" {
  type = bool
}

variable "vm_linux_size" {
  type = string
}

variable "vm_linux_image_sku" {
  type = string
}
