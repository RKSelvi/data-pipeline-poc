# Data Pipeline POC

- Terraform code (Iac) to deploy data related AZ resources
- GitHub Actions CI/CD pipeline

## Getting Started

1. [Install latest PowerShell](https://github.com/PowerShell/PowerShell/releases])
2. [Install Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli)
3. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [Learn Terraform](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code)

## Create client id & client secret

Pipeline deployment cannot be done with user login/credentials but only with servide principal. The service principal should have proper privilege to access resource group/subscription.

```
az ad sp create-for-rbac --name "{sp-name}" --sdk-auth --role contributor --scopes /subscriptions/{subscription-id}
```

## Log into azure account with service principal

### This is to create remote backend and if you are testing Terraform code manually from Azure Cli/PowerShell

```
az login
az account set --subscription [SUBSCRIPTION_ID]

az login --service-principal --username [CLIENT_ID] --password [CLIENT_SECRET] --tenant [TENANT_ID]
```

### If you are testing with CI/CD GitHub Actions, GitHub secrets should be updated in the repo with client id and client secret

## Create AzureRm backend storage account

- Update with values to create remote backend state [create-remote-state](./create-terraform-remote-state.ps1) and execute the Azure Cli commands to create resource group, storage account, and container.
- Update the 'provider "azurerm"' in [main.tf](./main.tf) with the values you have used to store the backend remote state