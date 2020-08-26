
resource "azurerm_resource_group" "costco" {
  name     = "costco"
  location = "westus"
}

terraform {
  backend "azurerm"
  resource_group_name  = azurerm_resource_group.costco.name
  storage_account_name = "ignw"
  containter_name      = "ignw"
  key                  = "terraform.state"
}
