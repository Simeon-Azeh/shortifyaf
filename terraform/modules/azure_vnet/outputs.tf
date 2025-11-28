output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in azurerm_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in azurerm_subnet.private : subnet.id]
}