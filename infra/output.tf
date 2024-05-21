output "azure_vm_public_ip_address" {
  value = var.enable_virtual_machine ? module.vm_linux[0].public_ip : null
}

output "azure_ssh_vm" {
  value = var.enable_virtual_machine ? "ssh -i keys/temp_key azureuser@${module.vm_linux[0].public_ip}" : null
}

output "webapp_default_hostname" {
  value = var.enable_webapp ? module.webapp[0].default_hostname : null
}

output "webapp_identity_principal_id" {
  value = var.enable_webapp ? module.webapp[0].webapp_identity_principal_id : null
}

output "webapp_identity_tenant_id" {
  value = var.enable_webapp ? module.webapp[0].webapp_identity_tenant_id : null
}

output "mssql_database_name" {
  value = module.mssql.database_name
}
