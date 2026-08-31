# ==========================================
# General Variables
# ==========================================

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
}

variable "app_service_subnet_name" {
  description = "App Service VNet Integration subnet name"
  type        = string
}

variable "app_service_subnet_address_prefixes" {
  description = "App Service VNet Integration subnet address prefixes"
  type        = list(string)
}

variable "private_endpoint_subnet_name" {
  description = "Private Endpoint subnet name"
  type        = string
}

variable "private_endpoint_subnet_address_prefixes" {
  description = "Private Endpoint subnet address prefixes"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "managed_by" {
  description = "Resource management identifier"
  type        = string
}


# ==========================================
# Azure SQL Variables
# ==========================================

variable "sql_server_name" {
  description = "Azure SQL Server name"
  type        = string
}

variable "sql_server_version" {
  description = "Azure SQL server version"
  type        = string
}

variable "sql_database_name" {
  description = "Azure SQL database name"
  type        = string
}

variable "sql_database_sku_name" {
  description = "Azure SQL database SKU"
  type        = string
}

variable "sql_database_max_size_gb" {
  description = "Maximum Azure SQL database size in GB"
  type        = number
}

variable "sql_entra_admin_login_name" {
  description = "Microsoft Entra administrator login name"
  type        = string
}

variable "sql_entra_admin_object_id" {
  description = "Microsoft Entra administrator object ID"
  type        = string
}


# ==========================================
# Azure SQL Role Variables
# ==========================================

variable "sql_database_role_name" {
  description = "Azure SQL database role assigned to the App Service Managed Identity"
  type        = string
}


# ==========================================
# App Service Variables
# ==========================================

variable "app_service_plan_name" {
  description = "App Service Plan name"
  type        = string
}

variable "app_service_name" {
  description = "Azure App Service name"
  type        = string
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type        = string
}

variable "app_service_runtime_stack" {
  description = "Application runtime stack version"
  type        = string
}

variable "app_service_https_only" {
  description = "Force HTTPS for App Service"
  type        = bool
}


# ==========================================
# App Service Managed Identity
# ==========================================

variable "app_service_identity_type" {
  description = "Managed identity type for the App Service"
  type        = string
  default     = "SystemAssigned"

  validation {
    condition = contains(
      ["SystemAssigned", "None"],
      var.app_service_identity_type
    )

    error_message = "Identity type must be SystemAssigned or None."
  }
}


# ==========================================
# Monitoring Variables
# ==========================================

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
}

variable "log_analytics_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Log Analytics data retention in days"
  type        = number
}

variable "application_insights_name" {
  description = "Application Insights resource name"
  type        = string
}

variable "application_insights_type" {
  description = "Application Insights application type"
  type        = string
}

variable "application_insights_retention_days" {
  description = "Application Insights retention in days"
  type        = number
}


# ==========================================
# Key Vault Variables
# ==========================================

variable "key_vault_name" {
  description = "Azure Key Vault name"
  type        = string
}

variable "key_vault_sku_name" {
  description = "Key Vault SKU"
  type        = string
}

variable "key_vault_public_network_access_enabled" {
  description = "Enable public network access to Key Vault"
  type        = bool
}

variable "key_vault_soft_delete_retention_days" {
  description = "Key Vault soft delete retention period"
  type        = number
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable Key Vault purge protection"
  type        = bool
}

variable "key_vault_private_dns_zone_name" {
  description = "Private DNS zone name for Key Vault"
  type        = string
}