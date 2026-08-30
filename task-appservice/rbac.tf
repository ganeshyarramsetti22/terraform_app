# ==========================================
# App Service → Key Vault
# Secrets User RBAC
# ==========================================

resource "azurerm_role_assignment" "app_service_key_vault_secrets_user" {
  scope = azurerm_key_vault.main.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_web_app.main.identity[0].principal_id
}