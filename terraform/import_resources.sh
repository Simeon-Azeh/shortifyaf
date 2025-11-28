#!/usr/bin/env bash
set -euo pipefail

# Usage: ./import_resources.sh -s <subscription_id> -g <resource_group>
# Example: ./import_resources.sh -s a07834e8-091a-422c-a06e-04ca54a705fb -g shortifyaf-rg

MODE="import"
while getopts s:g:m: flag
do
    case "${flag}" in
        s) SUBSCRIPTION_ID=${OPTARG};;
        g) RESOURCE_GROUP=${OPTARG};;
        m) MODE=${OPTARG};;
    esac
done

: ${SUBSCRIPTION_ID:?"Subscription ID is required. Use -s <subscription_id>"}
: ${RESOURCE_GROUP:?"Resource group is required. Use -g <resource_group>"}

# Helper prefix
SUBS="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers"

if [ "${MODE}" = "list" ]; then
    echo "Listing resources in ${RESOURCE_GROUP}..."
    az resource list -g ${RESOURCE_GROUP} -o table
    echo "\nSuggested import commands (review before running):\n"
    echo "terraform import 'module.acr.azurerm_container_registry.acr' \"${SUBS}/Microsoft.ContainerRegistry/registries/<acr-name>\""
    echo "terraform import 'module.vnet.azurerm_virtual_network.this' \"${SUBS}/Microsoft.Network/virtualNetworks/<vnet-name>\""
    echo "terraform import 'module.compute.azurerm_network_security_group.bastion_nsg' \"${SUBS}/Microsoft.Network/networkSecurityGroups/<bastion-nsg-name>\""
    echo "terraform import 'module.compute.azurerm_network_security_group.app_nsg' \"${SUBS}/Microsoft.Network/networkSecurityGroups/<app-nsg-name>\""
    echo "terraform import 'module.compute.azurerm_public_ip.bastion_pip' \"${SUBS}/Microsoft.Network/publicIPAddresses/<bastion-pip-name>\""
    echo "terraform import 'module.compute.azurerm_public_ip.app_lb_pip[0]' \"${SUBS}/Microsoft.Network/publicIPAddresses/<app-lb-pip-name>\""
    echo "terraform import 'module.postgres.azurerm_postgresql_flexible_server.postgres' \"${SUBS}/Microsoft.DBforPostgreSQL/flexibleServers/<postgres-name>\""
    exit 0
fi

echo "Importing ACR..."
terraform import 'module.acr.azurerm_container_registry.acr' "${SUBS}/Microsoft.ContainerRegistry/registries/shortifyafdevacr" || true

echo "Importing VNet..."
terraform import 'module.vnet.azurerm_virtual_network.this' "${SUBS}/Microsoft.Network/virtualNetworks/shortifyaf-dev-vnet" || true

echo "Importing NSGs..."
terraform import 'module.compute.azurerm_network_security_group.bastion_nsg' "${SUBS}/Microsoft.Network/networkSecurityGroups/bastion-nsg-dev" || true
terraform import 'module.compute.azurerm_network_security_group.app_nsg'    "${SUBS}/Microsoft.Network/networkSecurityGroups/app-nsg-dev"    || true

echo "Importing Public IPs..."
terraform import 'module.compute.azurerm_public_ip.bastion_pip'   "${SUBS}/Microsoft.Network/publicIPAddresses/bastion-pip-dev" || true
terraform import 'module.compute.azurerm_public_ip.app_lb_pip[0]' "${SUBS}/Microsoft.Network/publicIPAddresses/app-lb-pip-dev" || true

echo "Importing PostgreSQL Flexible Server..."
terraform import 'module.postgres.azurerm_postgresql_flexible_server.postgres' "${SUBS}/Microsoft.DBforPostgreSQL/flexibleServers/shortifyaf-pg-dev" || true

# Add additional imports as needed (network interfaces, NICs, etc.)

# Show current state resources for confirmation
terraform state list | sed -n '1,200p'

echo "Done. If you need to add additional imports, edit this script and rerun with the same args."