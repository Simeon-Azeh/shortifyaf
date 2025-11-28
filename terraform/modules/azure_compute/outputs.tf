output "bastion_public_ip" {
  description = "Public IP address of the bastion VM"
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "app_private_ip" {
  description = "Private IP address of the app VM"
  value       = azurerm_network_interface.app_nic.private_ip_address
}

output "app_public_ip" {
  description = "Public IP address of the app VM (if enabled)"
  value       = var.make_app_public ? azurerm_public_ip.app_pip[0].ip_address : null
}

output "bastion_nsg_id" {
  description = "ID of the bastion NSG"
  value       = azurerm_network_security_group.bastion_nsg.id
}

output "app_nsg_id" {
  description = "ID of the app NSG"
  value       = azurerm_network_security_group.app_nsg.id
}