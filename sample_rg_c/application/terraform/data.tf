data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_availability_set" "main" {
  name                = var.availability_set_name
  resource_group_name = data.azurerm_resource_group.main.name
}
