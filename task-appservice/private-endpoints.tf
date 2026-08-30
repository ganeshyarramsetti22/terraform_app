# ==========================================
# SQL Private Endpoint
# ==========================================

resource "azurerm_private_endpoint" "sql" {
  name                = "${var.sql_server_name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.sql_server_name}-private-connection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name = "sql-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.sql.id
    ]
  }
}

# ==========================================
# SQL Private DNS Zone
# ==========================================

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# ==========================================
# SQL Private DNS Zone - VNet Link
# ==========================================

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# ==========================================
# Key Vault Private Endpoint
# ==========================================

resource "azurerm_private_endpoint" "key_vault" {
  name                = "${var.key_vault_name}-pe"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  subnet_id = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.key_vault_name}-private-connection"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false

    subresource_names = [
      "vault"
    ]
  }

  private_dns_zone_group {
    name = "key-vault-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }
}

# ==========================================
# Key Vault Private DNS Zone
# ==========================================

resource "azurerm_private_dns_zone" "key_vault" {
  name                = var.key_vault_private_dns_zone_name
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}

# ==========================================
# Key Vault Private DNS Zone - VNet Link
# ==========================================

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "${var.key_vault_name}-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.main.id

  registration_enabled = false
}