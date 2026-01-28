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

module "staticwebapp" {
  source = "git::https://github.com/darshanthenge03-cloud/terraform-azure-modules.git//staticwebapp?ref=main"

  name                = var.static_web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}



