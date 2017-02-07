#!/bin/bash
#set -o errexit -o pipefail

ENV_SETUP=".env"
source "$ENV_SETUP"

if [ ! -d "tmp" ]; then
  mkdir tmp
fi

azure login
azure account set ${AZURE_SUBSCRIPTION}
azure config mode arm
azure group create --location ${AZURE_LOCATION} --name ${AZURE_RESOURCE_GROUP}
azure storage account create --sku-name RAGRS ${AZURE_STORAGE_ACCOUNT} -g ${AZURE_RESOURCE_GROUP}  -l ${AZURE_LOCATION} --kind storage
azure group deployment create --template-uri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/101-acs-dcos/azuredeploy.json --parameters-file templates/params.json ${AZURE_RESOURCE_GROUP} dcosDeploy