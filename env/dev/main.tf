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
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules/tree/342b694a7d71598788b95f874fe1136322c887ad/network"
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
}

# --------------------
# Key Vault
# --------------------
module "keyvault" {
  source              = "git::https://github.com/ORG/terraform-azure-modules.git//keyvault"
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
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules/tree/342b694a7d71598788b95f874fe1136322c887ad/vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  vm_name        = "xpay-vm01"
  vm_size        = "Standard_B2s"
  subnet_id      = module.network.private_subnet_ids["private-a"]
  admin_username = var.vm_admin_username
  os_type        = "linux"

  ssh_public_key = var.ssh_public_key

  image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# --------------------
# Bastion
# --------------------
module "bastion" {
  source              = "git::https://github.com/ORG/terraform-azure-modules.git//bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  bastion_subnet_id   = module.network.bastion_subnet_id
}

# --------------------
# Backup
# --------------------
module "backup" {
  source              = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules/tree/342b694a7d71598788b95f874fe1136322c887ad/backup"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  vault_name     = "rsv-xpay-dev"
  retention_days = 7
  vm_id          = module.vm.vm_id
}