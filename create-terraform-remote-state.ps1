#!/bin/bash


az group create --name tf_backend_rg --location eastus2

az storage account create --resource-group tf_backend_rg --name tfbkndsapoc --sku Standard_LRS --encryption-services blob

az storage account keys list --resource-group tf_backend_rg --account-name tfbkndsapoc --query [0].value -o tsv

az storage container create --name tfstatecont --account-name tfbkndsapoc --account-key [COPY_KEY_RETURNED_FROM_ABOVE_COMMAND]