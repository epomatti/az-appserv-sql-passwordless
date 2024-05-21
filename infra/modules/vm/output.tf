output "public_ip" {
  value = azurerm_public_ip.default.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.default.private_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.default.id
}
