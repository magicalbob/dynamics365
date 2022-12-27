resource "azurerm_public_ip" "dynadm" {
  name                    = "dynadm"
  location                = azurerm_resource_group.allinonerg.location
  resource_group_name     = azurerm_resource_group.allinonerg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "dynadmnetwork" {
  name                = "dynadm-nic"
  location            = azurerm_resource_group.allinonerg.location
  resource_group_name = azurerm_resource_group.allinonerg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dynamicssubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dynadm.id
  }
}

resource "azurerm_windows_virtual_machine" "dynadm" {
  name                  = "dynadm"
  location              = azurerm_resource_group.allinonerg.location
  resource_group_name   = azurerm_resource_group.allinonerg.name
  network_interface_ids = [azurerm_network_interface.dynadmnetwork.id]
  size                  = "Standard_B2s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "dynadm"
  admin_username = var.admin_user
  admin_password = var.admin_pass

  source_image_id = "/subscriptions/${var.subscription_id}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Compute/images/dynamics"

  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${var.admin_pass}</Value></Password><Enabled>true</Enabled><Username>${var.admin_user}</Username></AutoLogon>"
  }
}
