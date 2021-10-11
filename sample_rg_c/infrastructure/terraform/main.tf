resource "azurerm_resource_group" "main" {
  location = "westus"
  name     = "SAMPLE_C_RG"
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
  name                = "sample-cset"
}

resource "azurerm_virtual_desktop_workspace" "main" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  name          = "sample-workspace-c"
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

  registration_info {
    expiration_date = timeadd(timestamp(), "12h")
  }
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

# Potential crazy shenanigans below

resource "azurerm_key_vault_secret" "hostkey" {
  name         = "sample-c-hostkey" # "${var.rg_name}-hostkey"
  value        = azurerm_virtual_desktop_host_pool.main.registration_info[0].token
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_storage_blob" "main" {
  name                   = "sample_rg_c" # "${var.rg_name}"
  storage_account_name   = data.azurerm_storage_account.main.name
  storage_container_name = data.azurerm_storage_container.main.name
  type                   = "Block"
  content_type           = "text/plain"
  source_content         = "sample_rg_c,pooleddepthfirst" # "${var.rg_name},${var.hostpool_name}"

  depends_on = [
    azurerm_virtual_desktop_host_pool.main
  ]
}
