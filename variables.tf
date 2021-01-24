variable "subscription_id" {
  description = "The Azure subscription ID. Passed from ci-gh-terraform.yml"
}

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
variable "enabled_for_deployment" {
  type        = bool
  description = "Key Vault: Enabled for deployment setting. Setting: True/False"
}
variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Key Vault: Enabled for Enabled for Disk Encryption setting. Setting: True/False"
}
variable "enabled_for_template_deployment" {
  type        = bool
  description = "Key Vault: Enabled for Enabled for Template Deployment setting. Setting: True/False"
}
variable "enable_rbac_authorization" {
  type        = bool
  description = "Key Vault: Enabled/Disable for RBAC Authorization. Setting: True/False"
}
variable "soft_delete_retention_days" {
  type        = number
  description = "Key Vault: Specifies retention (in days) for soft delete setting. Days: 7, 14, 21, 30. etc."
}
variable "purge_protection_enabled" {
  type        = bool
  description = "Key Vault: Specifies if KeyVault purge protection should be enabled/disabled. Setting: True/False"
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