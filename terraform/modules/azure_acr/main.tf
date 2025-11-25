variable "project_name" {}
variable "environment" {}
variable "location" { default = "spaincentral" }
variable "resource_group_name" { type = string }

resource "azurerm_container_registry" "acr" {
  name                = lower("${var.project_name}${var.environment}acr")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
