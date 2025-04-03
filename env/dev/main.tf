# Invoca el módulo VNET y despliega recursos adicionales (ej. VM, Blob)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Crear Resource Group
resource "azurerm_resource_group" "this" {
  name     = "${var.env_name}-rg"
  location = var.location
}

# 2. Invocar el módulo de VNET
module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "${var.env_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  subnets             = var.subnets
}

# 3. Storage Account (usando un sufijo aleatorio)
resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.env_name}storage${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env_name
  }
}

# 4. Interfaz de red para la VM
resource "azurerm_network_interface" "this" {
  name                = "${var.env_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(module.vnet.subnet_ids, 0)
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.env_name
  }
}

# 5. Máquina Virtual (Linux)
resource "azurerm_linux_virtual_machine" "this" {
  name                = "${var.env_name}-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.env_name
  }
}
