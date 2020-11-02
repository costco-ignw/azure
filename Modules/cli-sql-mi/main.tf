variable "admin_password" {

}

variable "admin_user" {

}

variable "name" {

}

variable "resource_group_name" {

}

variable "subnet_id" {

}
/*
variable "capacity" {
  description = "The capacity of the managed instance in integer number of vcores."
  default     = 2
}

variable "license_type" {
  description = "The license type to apply for this managed instance. accepted values: BasePrice, LicenseIncluded"
  default     = "BasePrice"
}

variable "storagesize" {
  description = "The storage size of the managed instance. Storage size must be specified in increments of 32 GB."
  default     = "32"
}
*/
resource "null_resource" "azure_managed_instance" {
  triggers = {
    name                = var.name
    resource_group_name = var.resource_group_name
    subnet_id           = var.subnet_id
  }

  provisioner "local-exec" {
    on_failure = fail
    command    = "az storage account create  -n ${var.name} -g ${var.resource_group_name} -l ${var.location} --sku Standard_LRS"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = fail

    command = "az storage account delete -n ${self.triggers.name} -g ${self.triggers.resource_group_name} --yes"
  }
}
/*
resource "null_resource" "azure_managed_instance_capacity" {
  depends_on = [null_resource.azure_managed_instance]

  triggers = {
    admin_password      = var.admin_password
    name                = var.name
    resource_group_name = var.resource_group_name
    capacity            = var.capacity
  }

  provisioner "local-exec" {
    on_failure = fail
    command    = "az storage account update -g ${var.resource_group_name} -n ${var.name} -i -p ${var.admin_password} --capacity ${var.capacity}"
  }
}

resource "null_resource" "azure_managed_instance_license_type" {
  depends_on = [null_resource.azure_managed_instance]

  triggers = {
    admin_password      = var.admin_password
    name                = var.name
    resource_group_name = var.resource_group_name
    license_type        = var.license_type
  }

  provisioner "local-exec" {
    on_failure = fail
    command    = "az storage account update -g ${var.resource_group_name} -n ${var.name} -i -p ${var.admin_password} --license-type ${var.license_type}"
  }
}

resource "null_resource" "azure_managed_instance_storagesize" {
  depends_on = [null_resource.azure_managed_instance]

  triggers = {
    admin_password      = var.admin_password
    name                = var.name
    resource_group_name = var.resource_group_name
    storagesize         = var.storagesize
  }

  provisioner "local-exec" {
    on_failure = fail
    command    = "az storage account update -g ${var.resource_group_name} -n ${var.name} -i -p ${var.admin_password} --storage ${var.storagesize}"
  }
}
*/