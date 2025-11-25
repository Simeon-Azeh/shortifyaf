variable "project_name" {}
variable "environment" {}
variable "location" { default = "spaincentral" }
variable "resource_group_name" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-${var.environment}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public" {
  count               = length(var.public_subnet_cidrs)
  name                = "public-${count.index + 1}"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes    = [var.public_subnet_cidrs[count.index]]
}

resource "azurerm_subnet" "private" {
  count               = length(var.private_subnet_cidrs)
  name                = "private-${count.index + 1}"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes    = [var.private_subnet_cidrs[count.index]]
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnet_ids" {
  value = [for s in azurerm_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in azurerm_subnet.private : s.id]
}