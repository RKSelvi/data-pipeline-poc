terraform {
  required_providers {
    azurerm = "~> 2.78.0"
    azuread = "~> 1.6.0"
    databricks = {
      source = "databrickslabs/databricks"
      version = "0.3.7"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tf_backend_rg"
    storage_account_name = "tfbkndsapoc"
    container_name       = "tfstcont"
    key                  = "data-pipe.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_client_config" "current" {
}

// Create Resource Group
resource "azurerm_resource_group" "rgroup" {
  name     = var.resource_group_name
  location = var.location
}

// Create Databricks
resource "azurerm_databricks_workspace" "databricks" {
  name                          = var.databricks_name
  location                      = azurerm_resource_group.rgroup.location
  resource_group_name           = azurerm_resource_group.rgroup.name
  sku                           = "premium"
}

// Databricks Provider
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.databricks.id
  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id
}

resource "databricks_cluster" "databricks_cluster" {
  depends_on              = [azurerm_databricks_workspace.databricks]
  cluster_name            = var.databricks_cluster_name
  spark_version           = "8.2.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  driver_node_type_id     = "Standard_DS3_v2"
  autotermination_minutes = 15
  num_workers             = 5
  spark_env_vars          = {
    "PYSPARK_PYTHON" : "/databricks/python3/bin/python3"
  }
  spark_conf = {
    "spark.databricks.cluster.profile" : "serverless",
    "spark.databricks.repl.allowedLanguages": "sql,python,r"
  }
  custom_tags = {
    "ResourceClass" = "Serverless"
  }
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
}

// Create NetworkMonitoring Data Lake Directory
resource "azurerm_storage_data_lake_gen2_path" "networkmonitoring" {
  depends_on         = [azurerm_storage_data_lake_gen2_filesystem.datafiles]
  path               = "NetworkMonitoring"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.datafiles.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

// Create AzureMetrics Data Lake Directory
resource "azurerm_storage_data_lake_gen2_path" "azuremetrics" {
  depends_on         = [azurerm_storage_data_lake_gen2_filesystem.datafiles]
  path               = "AzureMetrics"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.datafiles.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
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
}

// Create Key Vault Secret (test value)
resource "azurerm_key_vault_secret" "testvalueone" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = "testvalueone"
  value        = "testvalueone"
  key_vault_id = azurerm_key_vault.keyvault.id
}

// Create Key Vault Secret (test value)
resource "azurerm_key_vault_secret" "testvaluethree" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = "testvaluethree"
  value        = "testvaluethree"
  key_vault_id = azurerm_key_vault.keyvault.id
}

// Create Key Vault Secret (test value two)
resource "azurerm_key_vault_secret" "testvaluetwo" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = "testvaluetwo"
  value        = "testvaluetwo"
  key_vault_id = azurerm_key_vault.keyvault.id
}

// Create Key Vault Secret (SQL Admin Password)
resource "azurerm_key_vault_secret" "admin_password" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = var.secret_name_admin_password
  value        = var.secret_value_admin_password
  key_vault_id = azurerm_key_vault.keyvault.id
}

//CreateKey Vault Secret (Data Lake Access Key)
resource "azurerm_key_vault_secret" "data_lake_access_key" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = "data-lake-access-key"
  value        = azurerm_storage_account.datalake.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_synapse_workspace" "pocsynapsewksp" {
  name                                 = var.synapse_server_name
  resource_group_name                  = azurerm_resource_group.rgroup.name
  location                             = azurerm_resource_group.rgroup.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.datafiles.id
  sql_administrator_login              = var.secret_value_admin_user
  sql_administrator_login_password     = var.secret_value_admin_password
  sql_identity_control_enabled         = true
}

resource "azurerm_synapse_sql_pool" "pocsynpsqlpl" {
  name                 = var.synapse_db_name
  synapse_workspace_id = azurerm_synapse_workspace.pocsynapsewksp.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  collation            = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

resource "azurerm_synapse_firewall_rule" "example" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.pocsynapsewksp.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

// CreateData Factory
resource "azurerm_data_factory" "datafactory" {
  name                = "adf-from-tf-code"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name
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