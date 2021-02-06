terraform {
  required_providers {
    azurerm = "~> 2.44.0"
  }

  backend "azurerm" {
    resource_group_name  = "tf_backend_rg"
    storage_account_name = "tfbkndsapoc"
    container_name       = "tfstcont"
    key                  = "data-pipe-poc.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

// Create Resource Group
resource "azurerm_resource_group" "rgroup" {
  name     = var.resource_group_name
  location = var.location
}

// Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "logw" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rgroup.name
}

// Create Data Lake
resource "azurerm_storage_account" "datalake" {
  name                     = var.data_lake_name
  resource_group_name      = azurerm_resource_group.rgroup.name
  location                 = azurerm_resource_group.rgroup.location
  account_tier             = var.data_lake_account_tier
  account_replication_type = var.data_lake_account_replication_type
  account_kind             = var.data_lake_account_kind
  is_hns_enabled           = "true"
  allow_blob_public_access = var.data_lake_allow_blob_public_access
}

// Create Data Lake File System
resource "azurerm_storage_data_lake_gen2_filesystem" "datafiles" {
  depends_on         = [azurerm_storage_account.datalake]
  name               = "data-files"
  storage_account_id = azurerm_storage_account.datalake.id
}

// Create NetworkAnalytics Data Lake Directory
resource "azurerm_storage_data_lake_gen2_path" "networkanalytics" {
  depends_on         = [azurerm_storage_data_lake_gen2_filesystem.datafiles]
  path               = "NetworkAnalytics"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.datafiles.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
  lifecycle {
    ignore_changes = [
      path,
      filesystem_name
    ]
  }
}

// Create NetworkMonitoring Data Lake Directory
resource "azurerm_storage_data_lake_gen2_path" "networkmonitoring" {
  depends_on         = [azurerm_storage_data_lake_gen2_filesystem.datafiles]
  path               = "NetworkMonitoring"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.datafiles.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
  lifecycle {
    ignore_changes = [
      path,
      filesystem_name
    ]
  }
}

// Create Key Vault
resource "azurerm_key_vault" "keyvault" {
  depends_on                      = [azurerm_storage_account.datalake]
  name                            = var.keyvault_name
  resource_group_name             = azurerm_resource_group.rgroup.name
  location                        = azurerm_resource_group.rgroup.location
  sku_name                        = var.keyvault_sku
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  tenant_id                       = var.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
    ]
    storage_permissions = [
      "set",
      "get",
      "delete",
      "list",
    ]
  }
}

// Create Key Vault Secret (SQL Admin UserName)
resource "azurerm_key_vault_secret" "admin_username" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = var.secret_name_admin_user
  value        = var.secret_value_admin_user
  key_vault_id = azurerm_key_vault.keyvault.id
  lifecycle {
    ignore_changes = [
      name,
      value
    ]
  }
}

// Create Key Vault Secret (SQL Admin Password)
resource "azurerm_key_vault_secret" "admin_password" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = var.secret_name_admin_password
  value        = var.secret_value_admin_password
  key_vault_id = azurerm_key_vault.keyvault.id
  lifecycle {
    ignore_changes = [
      name,
      value
    ]
  }
}

// Create MS SQL Server
resource "azurerm_mssql_server" "pocmssqlserver" {
  name                         = "datapocmssqlserver"
  resource_group_name          = azurerm_resource_group.rgroup.name
  location                     = azurerm_resource_group.rgroup.location
  version                      = "12.0"
  administrator_login          = var.secret_value_admin_user
  administrator_login_password = var.secret_value_admin_password
  minimum_tls_version          = "1.2"

  tags = {
    environment = "poc"
  }
}

resource "azurerm_synapse_workspace" "pocsynapsewksp" {
  name                                 = "datapocsynapsewksp"
  resource_group_name                  = azurerm_resource_group.rgroup.name
  location                             = azurerm_resource_group.rgroup.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.datafiles.id
  sql_administrator_login              = var.secret_value_admin_user
  sql_administrator_login_password     = var.secret_value_admin_password
}

resource "azurerm_synapse_sql_pool" "pocsynapsesqlpool" {
  name                 = "datapocsynapsesqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.example.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  collation            = "SQL_LATIN1_GENERAL_CP1_CS_AS"
}

// Create Auditing policy
resource "azurerm_mssql_server_extended_auditing_policy" "pocsqlserveraudpolicy" {
  server_id                               = azurerm_mssql_server.pocmssqlserver.id
  storage_endpoint                        = azurerm_storage_account.datalake.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.datalake.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
}

// Create Diagnostic Monitoring - Data Lake
resource "azurerm_monitor_diagnostic_setting" "diagmonitoringdatalake" {
  name                       = var.data_lake_diagnostic_monitoring_name
  target_resource_id         = azurerm_storage_account.datalake.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logw.id
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = false
    }
  }
  lifecycle {
    ignore_changes = [
      name,
      target_resource_id
    ]
  }
}

// Create Diagnostic Monitoring - Key Vault
resource "azurerm_monitor_diagnostic_setting" "diagmonitoringkeyvault" {
  name                       = var.key_vault_diagnostic_monitoring_name
  target_resource_id         = azurerm_key_vault.keyvault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logw.id
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = false
    }
  }
  lifecycle {
    ignore_changes = [
      name,
      target_resource_id
    ]
  }
}