# Documentación del módulo VNET
# Módulo de Virtual Network (VNET)

Este módulo crea una Virtual Network (VNET) y sus subredes en Azure.

## Uso

```hcl
module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "my-vnet"
  location            = "eastus"
  resource_group_name = "my-resource-group"
  address_space       = ["10.0.0.0/16"]
  subnets = [
    {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    }
  ]
}

Variables
vnet_name: Nombre de la VNET.

location: Región de Azure (eastus, westus, etc.).

resource_group_name: Grupo de recursos donde se creará la VNET.

address_space: Lista de rangos de direcciones (ej. ["10.0.0.0/16"]).

subnets: Lista de objetos con name y address_prefix.

Outputs
vnet_id: ID de la VNET creada.

subnet_ids: Lista de IDs de las subredes creadas.


---

## 4. Entorno **dev** en `env/dev/`

### 4.1 `env/dev/main.tf`

```hcl
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

# 1. Resource Group
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

# 3. Storage Account
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
