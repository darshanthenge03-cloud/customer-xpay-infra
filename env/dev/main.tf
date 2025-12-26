provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                = "kv-xpay-dev-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

data "azurerm_key_vault_secret" "test" {
  name         = "test-secret"
  key_vault_id = azurerm_key_vault.kv.id
}

output "keyvault_secret_loaded" {
  value     = length(data.azurerm_key_vault_secret.test.value) > 0
  sensitive = true
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
