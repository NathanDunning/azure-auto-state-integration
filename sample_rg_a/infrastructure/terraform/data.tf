data "azurerm_key_vault" "main" {
  name                = "eoufda-keyvault"
  resource_group_name = "COMMON_UTILS"
}

data "azurerm_storage_account" "main" {
  name                = "eoufdastorageaccount"
  resource_group_name = "COMMON_UTILS"
}

data "azurerm_storage_container" "main" {
  name                 = "deployed-rg"
  storage_account_name = data.azurerm_storage_account.main.name
}
