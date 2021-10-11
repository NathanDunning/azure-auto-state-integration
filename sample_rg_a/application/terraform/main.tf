resource "azurerm_resource_group" "main" {
  location = "westus"
  name     = "SAMPLE_RG_A"
}

resource "azurerm_virtual_network" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = "virtualNetwork1"
  address_space = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_availability_set" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "sample-aset-a"
}

resource "azurerm_virtual_desktop_workspace" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = "sample-workspace-a"
  friendly_name = "FriendlyName"
  description   = "A description of my workspace"
}

resource "azurerm_virtual_desktop_host_pool" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name                     = "pooleddepthfirst"
  friendly_name            = "pooleddepthfirst"
  description              = "Acceptance Test: A pooled host pool - pooleddepthfirst"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "DepthFirst"
}

resource "azurerm_virtual_desktop_application_group" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = "remoteappgroup"
  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.main.id
  friendly_name = "TestAppGroup"
  description   = "Acceptance Test: An application group"
}
