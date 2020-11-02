terraform {
  backend “azurerm” {
    storage_account_name = “sqlmistorage1"
    container_name       = “tfstate”
    key                  = “prod.terraform.tfstate”
    use_msi              = true
    subscription_id      = “b07cf94e-ce83-4d2d-99d6-28ce1a4daf7a”
    tenant_id            = “b81d7c17-75bd-4272-8b31-171ea6c31427"
  }
}