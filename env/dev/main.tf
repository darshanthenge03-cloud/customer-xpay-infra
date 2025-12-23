provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

# Call VM module
module "vm" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//vm"

  vm_name             = var.vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
}