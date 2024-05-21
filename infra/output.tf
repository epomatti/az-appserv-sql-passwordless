output "azure_vm_public_ip_address" {
  value = var.enable_virtual_machine ? module.vm_linux[0].public_ip : null
}

output "azure_ssh_vm" {
  value = var.enable_virtual_machine ? "ssh -i keys/temp_key azureuser@${module.vm_linux[0].public_ip}" : null
}
