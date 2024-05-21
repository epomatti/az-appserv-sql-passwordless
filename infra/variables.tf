### General ###
variable "location" {
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
