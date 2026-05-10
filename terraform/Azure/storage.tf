resource "azurerm_storage_account" "traific" {
  name                     = "traificdatalake${var.environment}"
  resource_group_name      = azurerm_resource_group.traific.name
  location                 = azurerm_resource_group.traific.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                    = ["AzureServices"]
    ip_rules                  = []
    virtual_network_subnet_ids = [azurerm_virtual_network.traific.subnet[0].id]
  }
}

resource "azurerm_storage_container" "datalake" {
  name                  = "datalake"
  storage_account_name  = azurerm_storage_account.traific.name
  container_access_type = "private"
}
