output "vnet_id" {
  description = "ID of the VNet"
  value       = module.vnet.vnet_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vnet.private_subnet_ids
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = module.compute.app_private_ip
}

output "app_public_ip" {
  description = "Public IP of the application server (only set when make_app_public = true)"
  value       = module.compute.app_public_ip
}

output "acr_login_server" {
  description = "Login server for Azure Container Registry"
  value       = module.acr.acr_login_server
}

/* duplicates removed */

output "app_dns_name" {
  description = "Public DNS or IP to reach your application (if app made public)"
  value       = module.compute.app_public_ip
}

output "postgres_fqdn" {
  description = "FQDN for the PostgreSQL flexible server"
  value       = module.postgres.postgres_fqdn
}

output "bastion_nsg_id" {
  description = "Network security group ID for bastion"
  value       = module.compute.bastion_nsg_id
}

output "app_nsg_id" {
  description = "Network security group ID for app VM"
  value       = module.compute.app_nsg_id
}

