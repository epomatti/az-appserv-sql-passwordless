data "azurerm_client_config" "current" {}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  config = jsonencode({
    "mssqlServer" : "${var.mssql_fqdn}",
    "mssqlDatabase" : "${var.mssql_database}",
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


### Private Endpoints ###
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.keyvault.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.keyvault.id
    ]
  }

  private_service_connection {
    name                           = "vault"
    private_connection_resource_id = azurerm_key_vault.default.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}
