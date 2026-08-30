# ==========================================
# Log Analytics Workspace
# ==========================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}

# ==========================================
# Application Insights
# ==========================================

resource "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  application_type = var.application_insights_type
  workspace_id     = azurerm_log_analytics_workspace.main.id

  retention_in_days = var.application_insights_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}