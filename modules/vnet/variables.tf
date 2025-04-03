# Variables parametrizables para el módulo VNET
variable "vnet_name" {
  type        = string
  description = "Nombre de la Virtual Network"
}

variable "location" {
  type        = string
  description = "Región de Azure donde se creará la VNET"
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group donde se creará la VNET"
}

variable "address_space" {
  type        = list(string)
  description = "Lista de rangos de direcciones para la VNET"
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  description = "Lista de subredes a crear dentro de la VNET"
  default = [
    {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    }
  ]
}
