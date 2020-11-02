terraform {
  backend "azurerm" {
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_name = "sqlmistorage1"
    container_name       = "tfstate"
    key                  = "npprod.terraform.tfstate"
  }
}