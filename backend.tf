terraform {
  backend "azurerm" {
    resource_group_name  = "sql-mi-poc"
    storage_account_name = "sqlmistorage1"
    container_name       = "tfstate"
    key                  = "npprod.terraform.tfstate"
  }
}