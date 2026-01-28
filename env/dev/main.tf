terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-customer-web"
  location = "East Asia"
}

module "static_web_app" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//static-web-app"

  name                = "customer-static-webapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = {
    environment = "prod"
    owner       = "customer"
  }
}
