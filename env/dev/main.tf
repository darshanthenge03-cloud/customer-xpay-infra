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
}