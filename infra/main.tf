terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.111.0"
    }
  }
}

resource "random_string" "generated" {
  length  = 5
  special = false
  upper   = false
}

locals {
  affix      = random_string.generated.result
  app        = "contoso"
  workload   = "${local.app}-${local.affix}"
  public_key = file("keys/temp_key.pub")
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  admin_ip_address    = var.admin_ip_address
}

module "mssql" {
  source   = "./modules/mssql"
  workload = local.workload
  group    = azurerm_resource_group.default.name
  location = azurerm_resource_group.default.location

  public_ip_address_to_allow    = var.admin_ip_address
  sku                           = var.mssql_sku
  max_size_gb                   = var.mssql_max_size_gb
  public_network_access_enabled = var.mssql_public_network_access_enabled
}

module "private_endpoints" {
  source                      = "./modules/private-endpoints"
  resource_group_name         = azurerm_resource_group.default.name
  location                    = azurerm_resource_group.default.location
  vnet_id                     = module.vnet.vnet_id
  mssql_server_id             = module.mssql.server_id
  private_endpoints_subnet_id = module.vnet.private_endpoints_subnet_id
}

module "webapp" {
  count                             = var.enable_webapp ? 1 : 0
  source                            = "./modules/webapp"
  workload                          = local.workload
  resource_group_name               = azurerm_resource_group.default.name
  location                          = azurerm_resource_group.default.location
  sku_name                          = var.webapp_plan_sku_name
  subnet_id                         = module.vnet.webapp_subnet_id
  mssql_fully_qualified_domain_name = module.mssql.fully_qualified_domain_name
  mssql_database_name               = module.mssql.database_name
}

module "acr" {
  source              = "./modules/acr"
  workload            = "${local.app}${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "vm_linux" {
  count                 = var.enable_virtual_machine ? 1 : 0
  source                = "./modules/vm"
  workload              = local.workload
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  subnet_id             = module.vnet.default_subnet_id
  size                  = var.vm_linux_size
  image_sku             = var.vm_linux_image_sku
  public_key            = local.public_key
  container_registry_id = module.acr.id
}

module "entra" {
  source = "./modules/entra"
}

resource "azurerm_role_assignment" "docker_containers_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.entra.docker_container_service_principal_id
}

module "keyvault" {
  count                                 = var.enable_virtual_machine ? 1 : 0
  source                                = "./modules/keyvault"
  workload                              = local.workload
  resource_group_name                   = azurerm_resource_group.default.name
  location                              = azurerm_resource_group.default.location
  admin_ip_address                      = var.admin_ip_address
  virtual_machine_identity_principal_id = module.vm_linux[0].identity_principal_id
  docker_container_app_id               = module.entra.docker_container_client_id
  docker_container_app_password         = module.entra.docker_container_app_password
  vnet_id                               = module.vnet.vnet_id
  private_endpoints_subnet_id           = module.vnet.private_endpoints_subnet_id
  mssql_fqdn                            = module.mssql.fully_qualified_domain_name
  mssql_database                        = module.mssql.database_name
}
