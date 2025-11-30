output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "app_private_ip" {
  value = azurerm_network_interface.app_nic.private_ip_address
}

output "app_public_ip" {
  value = var.make_app_public ? azurerm_public_ip.app_lb_pip[0].ip_address : null
}

output "bastion_nsg_id" {
  value = azurerm_network_security_group.bastion_nsg.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app_nsg.id
}