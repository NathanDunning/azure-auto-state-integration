data "azurerm_resource_group" "main" {
  name = "SAMPLE_A_RG"
}

data "azurerm_virtual_network" "main" {
  name                = "virtualNetwork1"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "main" {
  name                 = "subnet1"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_availability_set" "main" {
  name                = "sample-aset"
  resource_group_name = data.azurerm_resource_group.main.name
}
