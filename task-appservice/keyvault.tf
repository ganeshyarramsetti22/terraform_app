# ==========================================
# Azure Key Vault
# ==========================================

resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = var.key_vault_sku_name

  # Use Azure RBAC instead of Key Vault access policies
  rbac_authorization_enabled = true

  # Disable public access
  public_network_access_enabled = var.key_vault_public_network_access_enabled

  soft_delete_retention_days = var.key_vault_soft_delete_retention_days

  purge_protection_enabled = var.key_vault_purge_protection_enabled

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}