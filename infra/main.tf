terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.104.2"
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
  workload   = "contoso-${local.affix}"
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

module "vm_linux" {
  count               = var.enable_virtual_machine ? 1 : 0
  source              = "./modules/vm"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.default_subnet_id
  size                = var.vm_linux_size
  image_sku           = var.vm_linux_image_sku
  public_key          = local.public_key
}
