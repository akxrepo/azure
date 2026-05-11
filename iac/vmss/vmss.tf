resource "azurerm_resource_group" "vmss_rg" {
  name     = "vmss-resource-group"
  location = "East US"
}

resource "azurerm_public_ip" "lb" {
  name                = "vmss-lb-public-ip"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "app" {
  name                = "vmss-alb"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.app.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.app.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.app.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_network_security_group" "vmss" {
  name                = "vmss-nsg"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name

  security_rule {
    name                       = "allow-http-from-internet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-from-vnet"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

locals {
  cloud_init = <<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - apache2
    runcmd:
      - systemctl enable --now apache2
      - bash -lc 'echo "served from $(hostname)" > /var/www/html/index.html'
  CLOUDINIT
}

resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "apache-vmss"
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  sku                 = var.vmss_sku
  instances           = var.instance_count
  admin_username      = var.admin_username
  upgrade_mode        = "Manual"
  custom_data         = base64encode(local.cloud_init)

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(file(pathexpand("~/ak.pub")))
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.app.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app.id]
    }
  }

  depends_on = [azurerm_lb_rule.http]
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "load_balancer_public_ip_resource_name" {
  value = azurerm_public_ip.lb.name
}
