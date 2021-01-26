resource "azurerm_resource_group" "allinonerg" {
  name     = "NetworkWatcherRG"
  location = "UK South"
}

//data "azurerm_image" "allinone" {
//  name                = "dynamics"
//  resource_group_name = "allinonerg"
//}

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

resource "azurerm_network_interface" "allinonenetwork" {
  name                = "allinone-nic"
  location            = azurerm_resource_group.allinonerg.location
  resource_group_name = azurerm_resource_group.allinonerg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.allinonesubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "allinone" {
  name                    = "allinone"
  location                = azurerm_resource_group.allinonerg.location
  resource_group_name     = azurerm_resource_group.allinonerg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_windows_virtual_machine" "allinone" {
  name                  = "allinone"
  location              = azurerm_resource_group.allinonerg.location
  resource_group_name   = azurerm_resource_group.allinonerg.name
  network_interface_ids = [azurerm_network_interface.allinonenetwork.id]
  size                  = "Standard_B2s"

  os_disk {
    caching       = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "allinone"
  admin_username = "${var.admin_user}"
  admin_password = "${var.admin_pass}"

  //source_image_id = data.azurerm_image.allinone.id
  source_image_id = "/subscriptions/${var.subscription_id}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Compute/images/dynamics"

  additional_unattend_content {
    //pass         = "oobeSystem"
    //component    = "Microsoft-Windows-Shell-Setup"
    setting      = "AutoLogon"
    content      = "<AutoLogon><Password><Value>${var.admin_pass}</Value></Password><Enabled>true</Enabled><Username>${var.admin_user}</Username></AutoLogon>"
  }
}

//data "azurerm_public_ip" "allinone-pip" {
////  name                = azurerm_public_ip.allinonerg.name
////  resource_group_name = azurerm_windows_virtual_machine.allinone.resource_group_name
////  resource_group_name = "allinonerg"
//  name                = "allinone-pip"
//  resource_group_name = azurerm_resource_group.allinonerg.name
//  allocation_method = "Dynamic"
//}

//output "public_ip_address" {
//  value = data.azurerm_public_ip.allinone-pip.ip_address
//}
