resource "azurerm_virtual_network" "tesla" {
  name                = "tesla"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.tesla.location
  resource_group_name = azurerm_resource_group.tesla.name
}


resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.tesla.name
  virtual_network_name = azurerm_virtual_network.tesla.name
  address_prefix       = "10.20.2.0/24"
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.tesla.name
  virtual_network_name = azurerm_virtual_network.tesla.name
  address_prefix       = "10.20.3.0/24"
}