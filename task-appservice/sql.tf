resource "azurerm_mssql_server" "main" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  version                       = var.sql_server_version
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = var.sql_entra_admin_login_name
    object_id                   = var.sql_entra_admin_object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true

  }

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}

resource "azurerm_mssql_database" "main" {
  name        = var.sql_database_name
  server_id   = azurerm_mssql_server.main.id
  sku_name    = var.sql_database_sku_name
  max_size_gb = var.sql_database_max_size_gb

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}