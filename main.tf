provider "azurerm" {
  version = "~> 2.26"
  features {

  }
}

locals {
  location = "West US 2"
}

resource "azurerm_resource_group" "rg" {
  name     = "sql-mi-poc"
  location = local.location
}

module "vnet" {
  source              = "./Modules/sqlmi-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  #route_table_name    = "sql-mi-routetable"
  vnet_name = "sql-mi-vnet"
  #vnet_address_space  = "10.0.0.0/16"
  location    = "West US 2"
  subnet_name = "sql-mi-subnet"
  subnet_cidr = "10.0.0.0/28"
  nsg_name    = "sql-mi-nsg"
}

module "sql_mi" {
  source = "./Modules/cli-sql-mi"
  #admin_password      = "StrongPassword!@"
  #admin_user          = "adminuser"
  name                = "samplesqlmi"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.vnet.subnet_id
  #capacity            = 2
  #license_type        = "BasePrice"
  #storagesize         = 128

}
