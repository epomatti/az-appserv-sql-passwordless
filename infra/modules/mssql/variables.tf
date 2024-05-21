variable "group" {
  type = string
}

variable "location" {
  type = string
}

variable "workload" {
  type = string
}

variable "sku" {
  type = string
}

variable "max_size_gb" {
  type = number
}

variable "public_network_access_enabled" {
  type = bool
}

variable "public_ip_address_to_allow" {
  type = string
}
