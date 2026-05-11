resource "azurerm_mssql_server" "traific" {
  name                         = "traific-sqlserver-${var.environment}"
  resource_group_name          = azurerm_resource_group.traific.name
  location                     = azurerm_resource_group.traific.location
  administrator_login          = "traific_admin"
  administrator_login_password = var.db_password
  minimum_tls_version         = "1.2"

  azuread_authentication_only = false
}

resource "azurerm_mssql_database" "traific" {
  name      = "traific_db"
  server_id = azurerm_mssql_server.traific.id
  sku_name  = "Basic"
  max_size_gb = 2

  threat_detection_policy {
    enabled                    = true
    disabled_alerts            = []
    email_account_admins       = true
    retention_days             = 30
    storage_account_access_key = azurerm_storage_account.traific.primary_access_key
    storage_endpoint          = azurerm_storage_account.traific.primary_blob_endpoint
  }
}

resource "azurerm_mssql_firewall_rule" "traific" {
  name             = "traific-aks-access"
  server_id        = azurerm_mssql_server.traific.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}
