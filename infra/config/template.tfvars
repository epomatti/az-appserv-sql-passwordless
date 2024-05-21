### General ###
location = "eastus2"

### VNET ###
aws_vpc_cidr                           = "10.0.0.0/16"
aws_remote_gateway_ip_address_tunnel_1 = ""
aws_remote_gateway_ip_address_tunnel_2 = ""
local_administrator_ip_address         = ""

### Virtual Machine ###
enable_virtual_machine = true
vm_linux_size          = "Standard_B2pts_v2"
vm_linux_image_sku     = "22_04-lts-arm64"

### Firewall ###
enable_firewall  = true
firewall_name    = "pfsense"
firewall_vm_size = "Standard_B2als_v2"

firewall_image_publisher = "netgate"
firewall_image_offer     = "pfsense-plus-public-cloud-fw-vpn-router"
firewall_image_sku       = "pfsense-plus-public-tac-lite"
firewall_image_version   = "latest"

firewall_plan_name      = "pfsense-plus-public-tac-lite"
firewall_plan_publisher = "netgate"
firewall_plan_product   = "pfsense-plus-public-cloud-fw-vpn-router"
