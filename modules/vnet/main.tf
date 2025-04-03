# Código de Terraform para VNET y subredes
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  count                 = length(var.subnets)
  name                  = var.subnets[count.index].name
  resource_group_name   = var.resource_group_name
  virtual_network_name  = azurerm_virtual_network.this.name
  address_prefixes      = [ var.subnets[count.index].address_prefix ]
}
