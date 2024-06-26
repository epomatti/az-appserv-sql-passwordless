resource "azurerm_public_ip" "default" {
  name                = "pip-${var.workload}-linux"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "default" {
  name                = "nic-${var.workload}-linux"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  username = "azureuser"
}

resource "azurerm_linux_virtual_machine" "default" {
  name                  = "vm-${var.workload}-linux"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = local.username
  network_interface_ids = [azurerm_network_interface.default.id]
  user_data             = filebase64("${path.module}/userdata/ubuntu.sh")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = local.username
    public_key = var.public_key
  }

  os_disk {
    name                 = "osdisk-linux-${var.workload}"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.image_sku
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_virtual_machine.default.identity[0].principal_id
}

# TODO: Confirm if this is required due to Azure CLI commands
resource "azurerm_role_assignment" "contributor" {
  scope                = var.container_registry_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.default.identity[0].principal_id
}
