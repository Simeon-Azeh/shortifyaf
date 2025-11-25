variable "project_name" {}
variable "environment" {}
variable "location" { default = "spaincentral" }
variable "resource_group_name" { type = string }

resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "${var.project_name}-pg-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name   = "B_Standard_B1ms" 
  storage_mb = 32768

  administrator_login          = "pgadmin"
  administrator_password       = random_password.postgres_password.result
  version                     = "13"

  zone = "2"

  public_network_access_enabled = true
}

# Open firewall rule to the whole world is NOT recommended; limit to 0.0.0.0/0 would allow everything.
# We will *not* create wide open access; user should create firewall rules for private subnets or the bastion IP.

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_admin_user" {
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
}

output "postgres_admin_password" {
  value     = random_password.postgres_password.result
  sensitive = true
}
