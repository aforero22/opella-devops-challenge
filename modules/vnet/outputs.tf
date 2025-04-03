# Outputs relevantes (IDs, etc.) del módulo VNET
output "vnet_id" {
  description = "ID de la Virtual Network creada"
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "IDs de las subredes creadas"
  value       = [for subnet in azurerm_subnet.this : subnet.id]
}
