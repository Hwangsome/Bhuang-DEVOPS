#!/bin/bash
set -e

# Script for terraform destroy operation

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

# Run Terraform destroy with configuration from YAML
echo "Destroying Terraform infrastructure..."
terraform destroy -var-file="${YML_FILE_NAME}" -auto-approve

echo "Terraform destroy completed successfully."
