#!/bin/bash


az group create --name [TF_BACKEND_RG] --location [TF_LOCATION]

az storage account create --resource-group [TF_BACKEND_RG] --name [TF_BACKEND_SA_NAME] --sku Standard_LRS --encryption-services blob

az storage account keys list --resource-group [TF_BACKEND_RG] --account-name [TF_BACKEND_SA_NAME] --query [0].value -o tsv

az storage container create --name [TF_BACKEND_SA_CONT] --account-name [TF_BACKEND_SA_NAME] --account-key [COPY_KEY_RETURNED_FROM_ABOVE_COMMAND]