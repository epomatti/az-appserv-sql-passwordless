output "webapp_identity_principal_id" {
  value = azurerm_linux_web_app.main.identity[0].principal_id
}

output "webapp_identity_tenant_id" {
  value = azurerm_linux_web_app.main.identity[0].tenant_id
}

output "default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}
