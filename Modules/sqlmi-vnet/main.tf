# https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/connectivity-architecture-overview#network-requirements

/*
# This Route Table will be populated with routes by the sql-mi command
resource "azurerm_route_table" "rt" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

}
*/
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}
/*
resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.rt.id
  # The Route Table Cannot be disassociated from the subnet while there are still routes in the Route Table.  
  # This insures that the delete provisioner runs on the null_resource, which deletes all routes, before disassociating the subnet

}

resource "null_resource" "route_table_cleanup" {

  depends_on = [azurerm_subnet_route_table_association.subnet_route_table]

  triggers = {
    resource_group_name = var.resource_group_name
    route_table_name    = var.route_table_name
  }


  provisioner "local-exec" {
    when       = destroy
    on_failure = continue

    command = <<EOT
    $ids = az network route-table route list --resource-group ${self.triggers.resource_group_name} --route-table-name ${self.triggers.route_table_name} --query [].id --output tsv
    foreach ($id in $ids) {  az network route-table route delete --ids $id}
    EOT
  }
}
*/

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


output "subnet_id" {
  # without the depends_on, TF will only set a dependency on the actual subnet.  The SQL MI commands will fail if the NSG and Route Table associations are not complete.
  # The depends_on will make sure that the module will not return the subnet.id until those are completed.

  depends_on = [
    azurerm_subnet_network_security_group_association.nsg_subnet
  ]
  value = azurerm_subnet.subnet.id
}