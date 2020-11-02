# Azure CLI Implementation of SQL Managed Instance in Terraform
At the current time, there is no support for SQL Managed instance in the AzureRM Terraform provider that is maintained by Microsoft and Hashicorp.  In order to support the automated creation and management of SQL Managed Instances until (or if!) it is officially supported in the AzureRM, this solution provides an alternative process to create and manage SQL MI using Terraform, that has all of the benefits of automation and the auditing that goes with it.  However, it does not address all of the issues with SQL MI that prevent the AzureRM provider from supporting SQL MI.  

## AzureRM Support
There is an open issue on AzureRM's Github page that explains some of the reasons that SQL MI is not supported

https://github.com/terraform-providers/terraform-provider-azurerm/issues/1747#issuecomment-708535278

# Description of the solution
The Azure Command Line Interface (CLI) is a command line interface that allows many Azure resources to be fully managed from the command line.  While this is powerful, it generally requires an actual user to run it from their machine. It can also put run the commands from a pipeline tool, but then there is an issue there will be one pipeline to create a resource, and another to update it, and a third to delete it, but none of the pipelines maintain the state of the other, so it is very difficult to determine the current state of the resource by looking at this histories of the pipelines.

### Azure CLI for SQL Managed Instance

https://docs.microsoft.com/en-us/cli/azure/sql/mi?view=azure-cli-latest

However, we can also run Azure CLI commands from within a Terraform configuration using provisioner blocks. By using Terraform's "null_resource" syntax, we can define the desired state of the configuration using standard Terraform syntax, and also get all of the auditing, history, and state files that Terraform brings.

https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource

## Null Resources
`null_resource` blocks in Terraform do not represent actual resources, but they do partcipate in the lifecycle of a Terraform configuration in term of being created when an `apply` is run, or being deleted when a `destroy` is run, or being recreated when a value has changed, and the resource needs to be destroyed and recreated.

## Description of the key null_resource block

The following null-resource block is declared in ./Modules/cli-sql-mi/main.tf.  It is the most relevant block of the solution.

```
resource "null_resource" "azure_managed_instance" {
  triggers = {
    name                = var.name
    resource_group_name = var.resource_group_name
    subnet_id           = var.subnet_id
  }

  provisioner "local-exec" {
    on_failure = fail
    command    = "az sql mi create --admin-password ${var.admin_password} --admin-user ${var.admin_user} --name ${var.name} --resource-group ${var.resource_group_name} --subnet ${var.subnet_id}"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = fail

    command = "az sql mi delete --name ${self.triggers.name} --resource-group ${self.triggers.resource_group_name} --yes"
  }
}
```

### Triggers block

The Triggers block defines which values should be used to determine if the `null_resource` has changed.  The first time the configuration is run, the values will be saved in the state file.  The second and subsequent times an apply is run on the configuration, the null resource will compare the new values (such as `var.name`, `var.resource_group_name`, etc.) to the values in the state file.  If none of them have changed, then the provisioner blocks will not be run.

However, if one of the values has changed, then the null_resource is considered to be tainted, and it will be destroyed, and recreated.  The next section on provisioners explains that in more detail.

### Provisioner blocks

There are two provisioner blocks in this null resource.  Both are set to `local-exec` which means the will run on the machine where the terraform configuration is running.  The other option is `remote-exec` which would cause the command to be run on some remote server, but that is not relevant to this solution.  See 'Caveats and Limitations' below

https://www.terraform.io/docs/provisioners/connection.html

The first provisioner block will run whenever the `null_resource` is being created.  The second block which has the line `when = destroy` will be run when ever the resource is destroyed.  

The actual commands being run are fairly straight-forward.  The first block creates a managed instance using the varable values provided.  The second block deletes the managed instance.  However, when deleting the SQL MI using the second block, the values come from `self.triggers`.  These are the values that were stored in the State file from the previous time the configuration was run.  These are the only values that are available to a provisioner using `when = destroy`.  The reason for this is that in the scenario where the values in the trigger have changed, the destroy provisioner will run first, and it needs to know the old values, and then the create (default) provisioner will run second using the new values provided by the variables.

https://www.terraform.io/docs/provisioners/

### Update null_resources
The main `null_resource` only supports creating and destroying of the Managed Instance.  It does not support any changes to the configuration.
However, the Azure CLI for SQL MI does support updating the Managed instance with an `update` command

To support scenarios where some of these values could be updated, there are additional null resource block that support various commands.  For example: 

```
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
    command    = "az sql mi update -g ${var.resource_group_name} -n ${var.name} -i -p ${var.admin_password} --capacity ${var.capacity}"
  }
}
```

The above block is used to change the `capacity` setting of the Managed Instance.  It only has a single provisioner block, and it will run the first time the configuration is applied, and on future applies only when one of the values in the `triggers` changes.  By including the value of the `capacity` variable in the triggers, this allows us to only run that script when it changes.  There is no need to destroy anything with this `null_resource`, and if the entire configuration is destroyed, the settings will simply be removed from the state file.  

This pattern in this simple block can be for all of the values that support simple updates.  It should be noted that all of these values could be combined into a single update statement that contains all of the values, but it seems to be more prudent to have the commands be more granular.  If multiple values from the update blocks change, it just means multiple update commands (one in each `null_resource` block) will be executed.

# Caveats and Limitations
If Hashicorp ever produces a supported provider for SQL MI, it should certainly be used instead of this solution.  This solution is fragile, in that the configuration doesn't truly know the state of SQL MI, and all of its supporting infrastructure.  It simply tracks the parameters used to run the various commands, and will re-apply them when something changes.

## Deployment Platform
While this solution is valid, and has been tested from the command line, determining what platform it should be run on is a one of the open questions.  Because the underlying commands require Azure CLI, that means that the cli must be installed whereever it is going to be run.  This is probably not going to be Terraform Enterprise (TFE) because we cannot install the cli on TFE.  However, there are other platforms that can run Terraform, including Azure Devops, Jenkins, Puppet, and perhaps other "pipeline" platforms.  As long as the platform supports secret management (for variables like the password) and a history of what was run, and who approved it, then the solution will be auditable.

Another possibility is to run it from within TFE, but to change the code execution to use a `remote-exec`, and specify a connection to a server or service that does have az cli installed.  This has not been tested.

# Existing Resources.
This solution is a complete, stand-alone solution, meaning it does not depend on any other resource being create ahead of time.  Realistically, the solution will be deployed to an environment where the Virtual Network (vnet), and perhaps some of the other resource have already been created.  In this case, the resources created in the `sqlmi-vnet` module would need to be exchange for `data` sources that allow terraform to reference existing resources.

https://www.terraform.io/docs/configuration/data-sources.html
