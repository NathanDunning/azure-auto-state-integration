resource "azurerm_network_interface" "main" {
  name                = "sample-rg-a-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "default-configuration"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "sample-rg-a-vm"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_B1s"
  timezone              = "New Zealand Standard Time"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  license_type          = "Windows_Client"
  availability_set_id   = data.azurerm_availability_set.main.id

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}
