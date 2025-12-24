provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

module "network" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//network"

  vnet_name           = "xpay-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  vnet_address_space = ["10.0.0.0/16"]

  public_subnets = {
    public-a = "10.0.1.0/24"
    public-b = "10.0.2.0/24"
  }

  private_subnets = {
    private-a = "10.0.11.0/24"
    private-b = "10.0.12.0/24"
  }

  # Enable Bastion Host
  enable_bastion         = true
  bastion_subnet_prefix  = "10.0.100.0/26"
}

module "vm" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//vm"

  vm_name             = var.vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key

  # 👇 VM goes into PRIVATE subnet
  subnet_id = module.network.private_subnet_ids["private-a"]
}
