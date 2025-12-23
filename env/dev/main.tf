provider "azurerm" {
  features {}
}

module "vm" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//vm"

  vm_name             = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group
  vm_size             = var.vm_size
  nic_id              = var.nic_id
  ssh_public_key      = var.ssh_public_key
}
