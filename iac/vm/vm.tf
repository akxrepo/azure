resource "azurerm_resource_group" "vm-rg" {
  name     = "vm-resource-group"
  location = "East US"
}

resource "azurerm_network_interface" "nic" {
  name                = "ubuntu-nic"
  location            = azurerm_resource_group.vm-rg.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_public_ip" "vm" {
  name                = "ubuntu-vm-public-ip"
  location            = azurerm_resource_group.vm-rg.location
  resource_group_name = azurerm_resource_group.vm-rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "vm" {
  name                = "ubuntu-vm-nsg"
  location            = azurerm_resource_group.vm-rg.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

locals {
  cloud_init = <<-CLOUDINIT
    #cloud-config
    runcmd:
      - apt update
      - apt install -y apache2
  CLOUDINIT
}

resource "azurerm_virtual_machine" "ubuntu" {
  provider                         = azurerm
  name                             = "ubuntu-vm"
  location                         = azurerm_resource_group.vm-rg.location
  resource_group_name              = azurerm_resource_group.vm-rg.name
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  vm_size = "Standard_DC1ds_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  storage_os_disk {
    name              = "ubuntu-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.admin_username
    custom_data    = base64encode(local.cloud_init)
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = trimspace(file(pathexpand("~/ak.pub")))
    }
  }

}
