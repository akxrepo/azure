resource "azurerm_virtual_network" "aks_nap" {
  name                = "aks-nap-vnet"
  location            = azurerm_resource_group.aks_nap_rg.location
  resource_group_name = azurerm_resource_group.aks_nap_rg.name
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.aks_nap_rg.name
  virtual_network_name = azurerm_virtual_network.aks_nap.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_public_ip" "nat" {
  name                = "aks-nap-nat-public-ip"
  location            = azurerm_resource_group.aks_nap_rg.location
  resource_group_name = azurerm_resource_group.aks_nap_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "aks_nap" {
  name                = "aks-nap-nat-gateway"
  location            = azurerm_resource_group.aks_nap_rg.location
  resource_group_name = azurerm_resource_group.aks_nap_rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "aks_nap" {
  nat_gateway_id       = azurerm_nat_gateway.aks_nap.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.aks_nap.id
}

resource "azurerm_subnet_nat_gateway_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.aks_nap.id
}
