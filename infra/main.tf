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
  workload   = "enterprise"
  public_key = file("keys/temp_key.pub")
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}-core-${local.affix}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "webapp" {
  source              = "./modules/webapp"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku_name            = var.webapp_plan_sku_name
  subnet_id           = module.vnet.webapp_subnet_id
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
