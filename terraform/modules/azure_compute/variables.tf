variable "project_name" {}
variable "environment" {}
variable "vm_size" { default = "Standard_B1s" }
variable "bastion_vm_size" { default = "Standard_B1s" }
variable "admin_ssh_public_key" { type = string }
variable "allowed_ssh_cidr" { type = list(string) }
variable "resource_group_name" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "location" { default = "spaincentral" }
variable "make_app_public" {
  type    = bool
  default = false
}

output "app_instance_id" {
  description = "ID of the app VM"
  value       = azurerm_linux_virtual_machine.app_vm.id
  depends_on  = [azurerm_network_interface.app_nic]
}

