
resource "azurerm_resource_group" "costco" {
  name     = "costco"
  location = "westus"
}


terraform {
  backend "azurerm" {
    resource_group_name  = "costco"
    storage_account_name = "ignw"
    container_name       = "ignw"
    subscription_id      = "a5e1f313-dcc0-4487-b6b6-ca9a628c4e87"
    key                  = "terraform.tfstate"
    access_key           = "LtT5h9p0LqReA/W8YlTpDrelUSlLXZFki+YzWPuFgaAmkKeZ+ztGi/6o1+ypzHOhJkCcOc4oC6wJIihOiWb/Fw=="
  }
}