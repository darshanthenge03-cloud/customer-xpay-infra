terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfxpaystate001"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}
