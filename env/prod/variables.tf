# Variables específicas del entorno prod
variable "env_name" {
  type        = string
  description = "Nombre del entorno (ej. dev, prod)"
}

variable "location" {
  type        = string
  description = "Región de Azure"
}

variable "address_space" {
  type        = list(string)
  description = "Espacio de direcciones para la VNET"
  default     = ["10.1.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  description = "Lista de subredes para la VNET"
  default = [
    {
      name           = "subnet1"
      address_prefix = "10.1.1.0/24"
    }
  ]
}

variable "admin_username" {
  type        = string
  description = "Nombre de usuario para la VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Llave pública SSH para acceso a la VM"
  default     = ""  # Reemplaza con tu llave pública
}
