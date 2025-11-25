resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "bastion-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH-From-Client"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-API"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3001"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # Allow SSH only from bastion subnet (we assume private subnets are used by app)
  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.public_subnet_cidrs
    destination_address_prefix = "*"
  }
}

# create public ip for bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# choose the first public subnet for the bastion
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-nic-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.public_subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }

}

resource "azurerm_network_interface" "app_nic" {
  name                = "app-nic-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.private_subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
  }

}

# Associate NSGs with the subnet (attach security controls at subnet level)
resource "azurerm_subnet_network_security_group_association" "bastion_subnet_assoc" {
  subnet_id                 = var.public_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_assoc" {
  subnet_id                 = var.private_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                = "bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.bastion_vm_size
  admin_username      = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.bastion_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "app-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.app_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # simple cloud-init to install Docker and run placeholder
  custom_data = base64encode(<<-CLOUD
#cloud-config
package_update: true
packages:
  - docker.io
runcmd:
  - systemctl enable docker
  - systemctl start docker
CLOUD
  )
}

# Public load balancer to forward HTTP and API traffic into app private NIC
resource "azurerm_public_ip" "app_lb_pip" {
  count               = var.make_app_public ? 1 : 0
  name                = "app-lb-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "app_lb" {
  count               = var.make_app_public ? 1 : 0
  name                = "app-lb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.app_lb_pip[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "app_backend" {
  count               = var.make_app_public ? 1 : 0
  name                = "app-backend-${var.environment}"
  loadbalancer_id     = azurerm_lb.app_lb[0].id
}

resource "azurerm_lb_probe" "http" {
  count               = var.make_app_public ? 1 : 0
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.app_lb[0].id
  protocol            = "Http"
  port                = 3000
  request_path        = "/"
}

resource "azurerm_lb_rule" "http" {
  count               = var.make_app_public ? 1 : 0
  name                = "http-rule"
  loadbalancer_id     = azurerm_lb.app_lb[0].id
  protocol            = "Tcp"
  frontend_port       = 80
  backend_port        = 3000
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.app_backend[0].id]
  probe_id                       = azurerm_lb_probe.http[0].id
}

resource "azurerm_lb_rule" "api" {
  count               = var.make_app_public ? 1 : 0
  name                = "api-rule"
  loadbalancer_id     = azurerm_lb.app_lb[0].id
  protocol            = "Tcp"
  frontend_port       = 3001
  backend_port        = 3001
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.app_backend[0].id]
  probe_id                       = azurerm_lb_probe.http[0].id
}

# Register VM NIC with load balancer backend pool (if enabled)
resource "azurerm_network_interface_backend_address_pool_association" "app_assoc" {
  count                    = var.make_app_public ? 1 : 0
  network_interface_id     = azurerm_network_interface.app_nic.id
  ip_configuration_name    = "internal"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.app_backend[0].id
}

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
