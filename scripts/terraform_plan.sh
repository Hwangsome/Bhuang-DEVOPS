#!/bin/bash
set -e

# Script for terraform plan operation

# Required parameters
TEAMCITY_WORK_DIR=${TEAMCITY_WORK_DIR:-$(pwd)}
CONTEXT=${CONTEXT:-"dev"}
REGION=${REGION:-"us-west-1"}
LAYER_IDENTIFIER=${LAYER_IDENTIFIER:-"infra"}

# Construct YAML file path
YML_FILE_NAME="${TEAMCITY_WORK_DIR}/configs/${CONTEXT}.${REGION}.${LAYER_IDENTIFIER}.yml"

echo "Using configuration file: ${YML_FILE_NAME}"

if [ ! -f "${YML_FILE_NAME}" ]; then
  echo "Error: YAML file ${YML_FILE_NAME} not found!"
  exit 1
fi

# Run Terraform plan with configuration from YAML
echo "Planning Terraform changes..."
terraform plan -var-file="${YML_FILE_NAME}" -out=tfplan

echo "Terraform plan completed and saved to tfplan"
