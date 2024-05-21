data "azurerm_client_config" "current" {}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  config = jsonencode({
    "tenantId" : "${local.tenant_id}",
    "appId" : "${var.docker_container_app_id}",
    "appPassword" : "${var.docker_container_app_password}"
  })
}

resource "azurerm_key_vault" "default" {
  name                       = "kv-${var.workload}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = local.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true

  # Further controlled by network_acls below
  public_network_access_enabled = true

  network_acls {
    default_action = "Deny"
    ip_rules       = [var.admin_ip_address]
    bypass         = "AzureServices"
  }
}

resource "azurerm_role_assignment" "current" {
  scope                = azurerm_key_vault.default.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = local.object_id
}

resource "azurerm_role_assignment" "vm" {
  scope                = azurerm_key_vault.default.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.virtual_machine_identity_principal_id

  depends_on = [azurerm_role_assignment.current]
}

resource "azurerm_key_vault_secret" "docker_container_config" {
  name         = "docker-container-config"
  value        = local.config
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [azurerm_role_assignment.current]
}
