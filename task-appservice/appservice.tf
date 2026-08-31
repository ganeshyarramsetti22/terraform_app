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

  # ========================================
  # HTTPS
  # ========================================

  https_only = var.app_service_https_only


  # ========================================
  # System Assigned Managed Identity
  # ========================================

  identity {
    type = var.app_service_identity_type
  }


  # ========================================
  # Site Configuration
  # ========================================

  site_config {
    always_on = true

    # Route App Service outbound traffic
    # through the integrated VNet.

    vnet_route_all_enabled = true

    # Node.js startup command

    app_command_line = "npm start"

    # Node.js runtime

    application_stack {
      node_version = var.app_service_runtime_stack
    }
  }


  # ========================================
  # Application Logs
  # ========================================

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false

    http_logs {
      file_system {
        retention_in_days = 3
        retention_in_mb   = 100
      }
    }
  }


  # ========================================
  # Application Settings
  # ========================================
  #
  # IMPORTANT:
  # app_settings is OUTSIDE site_config.
  #

  app_settings = {
    # --------------------------------------
    # Application Insights
    # --------------------------------------
    #
    # Value comes from Key Vault through
    # an App Service Key Vault reference.
    #

    APPLICATIONINSIGHTS_CONNECTION_STRING = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)"


    # --------------------------------------
    # Azure SQL Server
    # --------------------------------------

    SQL_SERVER_NAME = "${var.sql_server_name}.database.windows.net"


    # --------------------------------------
    # Azure SQL Database
    # --------------------------------------

    SQL_DATABASE_NAME = var.sql_database_name
  }


  # ========================================
  # Tags
  # ========================================

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

  subnet_id = azurerm_subnet.app_service_integration.id
}