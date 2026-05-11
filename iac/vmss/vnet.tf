resource "azurerm_virtual_network" "vmss" {
  name                = "vmss-vnet"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.vmss_rg.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "nat" {
  name                = "vmss-nat-public-ip"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "vmss" {
  name                = "vmss-nat-gateway"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "vmss" {
  nat_gateway_id       = azurerm_nat_gateway.vmss.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.vmss.id
}

resource "azurerm_subnet_nat_gateway_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.vmss.id
}
