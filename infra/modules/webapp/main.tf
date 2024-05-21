resource "azurerm_service_plan" "main" {
  name                = "plan-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  public_network_access_enabled = true
  https_only                    = true
  virtual_network_subnet_id     = var.subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on         = true
    health_check_path = "/"

    application_stack {
      # docker_image_name = "index.docker.io/nginx:latest"
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    DOCKER_ENABLE_CI         = false
    WEBSITE_RUN_FROM_PACKAGE = "1"
    # WEBSITES_PORT            = "80"
    MSSQL_FQDN               = var.mssql_fully_qualified_domain_name
    MSSQL_DB_NAME            = var.mssql_database_name
  }
}
