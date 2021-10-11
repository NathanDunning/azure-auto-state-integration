resource "azurerm_resource_group" "main" {
  location = "australiaeast"
  name     = "COMMON_UTILS"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "${random_string.random.result}-keyvault"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Set", "List"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "${random_string.random.result}storageaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "main" {
  name                  = "deployed-rg"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "random_string" "random" {
  length  = 6
  special = false
  number  = false
  upper   = false
}
