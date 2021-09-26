variable "tenant_id" {
  description = "The Azure tenant ID for the service principal. Passed from ci-gh-terraform.yml"
}

variable "location" {
  type        = string
  description = "The location to deploy the resources to"
}

variable "resource_group_name" {
  description = "Resource Group: Name"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics Workspace: Name"
}

variable "data_lake_name" {
  type        = string
  description = "Data Lake: Name"
}

variable "data_lake_file_system_name" {
  type        = string
  description = "Data Lake File System: Name"
}

variable "data_lake_account_tier" {
  type        = string
  description = "Data Lake: Account Tier. Valid values: Standard and Premium"
}

variable "data_lake_account_replication_type" {
  type        = string
  description = "Data Lake: Account Replication Type.  Valid values: LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
}

variable "data_lake_account_kind" {
  type        = string
  description = "Data Lake: Type of account to use. Options: StorageV2 or BlobStorage"
}

variable "data_lake_allow_blob_public_access" {
  type        = string
  description = "Data Lake: Allow public access.  Valid values: true and false"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault: Name"
}

variable "keyvault_sku" {
  type        = string
  description = "Key Vault: SKU.  Valid values: standard and premium"
}

variable "secret_name_admin_user" {
  type        = string
  description = "KeyVault Secret Name: Admin UserName"
}

variable "secret_value_admin_user" {
  type        = string
  description = "KeyVault Secret Value: Admin UserName"
}

variable "secret_name_admin_password" {
  type        = string
  description = "KeyVault Secret Name: Admin Password"
}

variable "secret_value_admin_password" {
  type        = string
  description = "KeyVault Secret Value: Admin Password"
}

variable "key_vault_diagnostic_monitoring_name" {
  type        = string
  description = "Diagnostic Monitoring: Keyvault"
}

variable "data_lake_diagnostic_monitoring_name" {
  type        = string
  description = "Diagnostic Monitoring: Data Lake"
}

variable "synapse_server_name" {
  type        = string
  description = "Synapse server name"
}

variable "synapse_db_name" {
  type        = string
  description = "Synapse DB Name"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "client_secret" {
  type        = string
  description = "Client Secret"
}

variable "databricks_name" {
  type        = string
  description = "Databricks Name"
}

variable "databricks_cluster_name" {
  type        = string
  description = "Databricks Cluster Name"
}