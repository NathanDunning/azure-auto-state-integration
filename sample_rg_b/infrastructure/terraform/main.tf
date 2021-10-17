resource "azurerm_resource_group" "main" {
  location = "westus"
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = var.virtual_network_name
  address_space = ["10.0.0.0/16"]

  subnet {
    name           = var.subnet_name
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_availability_set" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = var.availability_set_name
}

resource "azurerm_virtual_desktop_workspace" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = var.workspace_name
  friendly_name = "FriendlyName"
  description   = "A description of my workspace"
}

resource "azurerm_virtual_desktop_host_pool" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name                     = var.host_pool_name
  friendly_name            = var.host_pool_name
  description              = "Acceptance Test: A pooled host pool - pooleddepthfirst"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "DepthFirst"

  registration_info {
    expiration_date = timeadd(timestamp(), "12h")
  }
}

resource "azurerm_virtual_desktop_application_group" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = var.application_group_name
  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.main.id
  friendly_name = "TestAppGroup"
  description   = "Acceptance Test: An application group"
}

# Potential crazy shenanigans below

resource "azurerm_key_vault_secret" "hostkey" {
  name         = lower(replace("${var.resource_group_name}-hostkey", "_", "-"))
  value        = azurerm_virtual_desktop_host_pool.main.registration_info[0].token
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_storage_blob" "main" {
  name                   = var.resource_group_name
  storage_account_name   = data.azurerm_storage_account.main.name
  storage_container_name = data.azurerm_storage_container.main.name
  type                   = "Block"
  content_type           = "text/plain"
  source_content         = "${var.resource_group_name},${var.host_pool_name}"

  depends_on = [
    azurerm_virtual_desktop_host_pool.main
  ]
}
