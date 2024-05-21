output "public_ip" {
  value = azurerm_public_ip.default.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.default.private_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.default.id
}

output "identity_principal_id" {
  value = azurerm_linux_virtual_machine.default.identity[0].principal_id
}
