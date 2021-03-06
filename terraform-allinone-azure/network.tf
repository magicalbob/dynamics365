resource "azurerm_virtual_network" "allinonenet" {
  name                = "allinone-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.allinonerg.location
  resource_group_name = azurerm_resource_group.allinonerg.name
}

resource "azurerm_subnet" "allinonesubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.allinonerg.name
  virtual_network_name = azurerm_virtual_network.allinonenet.name
  address_prefixes     = ["10.0.2.0/24"]
}
