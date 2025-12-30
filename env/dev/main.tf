provider "azurerm" {
  features {}
}

# --------------------
# Resource Group
# --------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# --------------------
# Network
# --------------------
module "network" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//network?ref=main"
  # or ref=v1.0.0 AFTER tagging

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_cidr           = "10.10.0.0/16"

  public_subnets = {
    public-a = "10.10.1.0/24"
    public-b = "10.10.2.0/24"
  }

  private_subnets = {
    private-a = "10.10.10.0/24"
    private-b = "10.10.11.0/24"
  }

  bastion_subnet_cidr = "10.10.255.0/27"
  gateway_subnet_cidr = "10.10.254.0/27"
}

# --------------------
# Key Vault
# --------------------
module "keyvault" {
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//keyvault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  key_vault_name      = "kv-xpay-dev"

  access_policies = [
    {
      object_id  = module.vm.vm_principal_id
      permissions = ["Get", "List"]
    }
  ]
}

# --------------------
# VM
# --------------------
module "vm" {
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  vm_name        = "xpay-vm01"
  vm_size        = "Standard_B2s"
  subnet_id      = module.network.private_subnet_ids["private-a"]
  admin_username = var.vm_admin_username
  os_type        = "linux"
  os_flavor      = "ubuntu-22.04"

  ssh_public_key = var.ssh_public_key

}

# --------------------
# Bastion
# --------------------
module "bastion" {
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  bastion_subnet_id   = module.network.bastion_subnet_id
}

# --------------------
# Backup
# --------------------
module "backup" {
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//backup"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  vault_name     = "rsv-xpay-dev"
  retention_days = 7
  vm_id          = module.vm.vm_id
}
# --------------------
# VPNGateway
# --------------------
module "vpngateway" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//vpngateway?ref=main"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  gateway_subnet_id = module.network.gateway_subnet_id
}
