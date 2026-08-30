# ==========================================
# App Service Plan
# ==========================================

resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  os_type  = "Linux"
  sku_name = var.app_service_plan_sku

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}

# ==========================================
# Azure Linux App Service
# ==========================================

resource "azurerm_linux_web_app" "main" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  service_plan_id = azurerm_service_plan.main.id

  # Force HTTPS
  https_only = var.app_service_https_only

  # ========================================
  # System Assigned Managed Identity
  # ========================================

  identity {
    type = "SystemAssigned"
  }

  # ========================================
  # Application Configuration
  # ========================================

  site_config {
    always_on = true

    application_stack {
      node_version = var.app_service_runtime_stack
    }
  }

  # ========================================
  # Application Insights
  # ========================================

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
  }

  tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.project_name
  }
}

# ==========================================
# App Service VNet Integration
# ==========================================

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = azurerm_subnet.app_service_integration.id
}