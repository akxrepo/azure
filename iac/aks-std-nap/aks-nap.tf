resource "azurerm_resource_group" "aks_nap_rg" {
  name     = "aks-nap-resource-group"
  location = "East US"
}

resource "azurerm_network_security_group" "aks_nap" {
  name                = "aks-nap-subnet-nsg"
  location            = azurerm_resource_group.aks_nap_rg.location
  resource_group_name = azurerm_resource_group.aks_nap_rg.name

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
    name                       = "allow-https-from-internet"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-lb-nodeports"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

resource "azurerm_kubernetes_cluster" "aks_nap" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_nap_rg.location
  resource_group_name = azurerm_resource_group.aks_nap_rg.name
  dns_prefix          = var.dns_prefix
  sku_tier            = "Standard"

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.app.id
    type           = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  # NAP-specific configuration
  node_provisioning_profile {
    mode               = "Auto"
    default_node_pools = "Auto"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.app,
    azurerm_subnet_nat_gateway_association.app,
  ]
}

output "aks_nap_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_nap.name
}

output "aks_nap_resource_group_name" {
  value = azurerm_resource_group.aks_nap_rg.name
}
