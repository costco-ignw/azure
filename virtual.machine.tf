# resource "azurerm_availability_set" "tesla" {
#   name                = "tesla"
#   location            = azurerm_resource_group.tesla.location
#   resource_group_name = azurerm_resource_group.tesla.name
# }

# resource "azurerm_network_interface" "tesla" {
#   name                = "web-nic"
#   location            = azurerm_resource_group.tesla.location
#   resource_group_name = azurerm_resource_group.tesla.name

#   ip_configuration {
#     name                          = "web"
#     subnet_id                     = azurerm_subnet.web.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_windows_virtual_machine" "tesla" {
#   name                = "web01"
#   resource_group_name = azurerm_resource_group.tesla.name
#   location            = azurerm_resource_group.tesla.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password      = "P@$$w0rd1234!"
#   availability_set_id = azurerm_availability_set.tesla.id
#   network_interface_ids = [
#     azurerm_network_interface.tesla.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }
# }