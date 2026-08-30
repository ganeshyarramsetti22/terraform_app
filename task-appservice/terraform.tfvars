location = "southafricanorth"

resource_group_name = "rg-appservice-gani"

vnet_name = "vnet-appservice"

vnet_address_space = [
  "10.0.0.0/16"
]

app_service_subnet_name = "subnet-appservice-integration-gani"

app_service_subnet_address_prefixes = [
  "10.0.1.0/24"
]

private_endpoint_subnet_name = "snet-private-endpoints-gani"

private_endpoint_subnet_address_prefixes = [
  "10.0.2.0/24"
]

environment = "dev"

project_name = "AppService"

managed_by = "Terraform"

# =========================
# Azure SQL Configuration
# =========================

sql_server_name = "sql-appservice-demo-gani"

sql_server_version = "12.0"

sql_database_name = "applicationdb"

sql_database_sku_name = "Basic"

sql_database_max_size_gb = 2

sql_entra_admin_login_name = "namratha.ellaboina_gmail.com#EXT#@namrathaellaboinagmail.onmicrosoft.com"

sql_entra_admin_object_id = "6ffb023d-82d9-495e-a91b-8488f8dc84ea"


# =========================
# App Service Configuration
# =========================

app_service_plan_name = "asp-appservice-demo-gani"

app_service_name = "appservice-demo-gani-2026"

app_service_plan_sku = "B1"

app_service_runtime_stack = "24-lts"

app_service_https_only = true

# =========================
# Monitoring Configuration
# =========================

log_analytics_workspace_name = "law-appservice-gani"

log_analytics_sku = "PerGB2018"

log_analytics_retention_days = 30

application_insights_name = "appi-appservice-gani"

application_insights_type = "web"

application_insights_retention_days = 90

# =========================
# Key Vault Configuration
# =========================

key_vault_name = "kv-appservice-gani-2026"

key_vault_sku_name = "standard"

key_vault_public_network_access_enabled = false

key_vault_soft_delete_retention_days = 7

key_vault_purge_protection_enabled = false

key_vault_private_dns_zone_name = "privatelink.vaultcore.azure.net"
sql_database_role_name          = "db_datareader"