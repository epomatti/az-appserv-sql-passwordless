### General ###
location         = "eastus2"
admin_ip_address = ""

### Azure SQL Databasea ###
mssql_public_network_access_enabled = true
mssql_sku                           = "Basic"
mssql_max_size_gb                   = 2

### App Service ###
enable_webapp        = false
webapp_plan_sku_name = "P1v3"

### Virtual Machine ###
enable_virtual_machine = true
vm_linux_size          = "Standard_B2s_v2"
vm_linux_image_sku     = "22_04-lts"
