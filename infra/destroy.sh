#!/bin/bash

set -e

############################################################################################
echo "checking prerequisite"
############################################################################################
if ! [ $(command -v terraform) ]; then
  echo "error: This script need the terraform binary."
  echo "You can follow the guide to install it : https://learn.hashicorp.com/terraform/getting-started/install.html"
  exit 1
fi

# if [ -z $GOOGLE_PROJECT ] || !$GOOGLE_REGION || !$GOOGLE_APPLICATION_CREDENTIALS; then
export GOOGLE_REGION=${GOOGLE_REGION:-europe-west1-b}
export GOOGLE_ZONE=${GOOGLE_ZONE:-europe-west1-b}
if [[ -z $GOOGLE_PROJECT || -z $GOOGLE_APPLICATION_CREDENTIALS ]]; then
    echo "error: missing environment configuration"
    echo "credentials: $GOOGLE_APPLICATION_CREDENTIALS"
    exit 1
fi

############################################################################################
echo "terraform destroy"
############################################################################################
export ARGO_WORKSPACE=${ARGO_WORKSPACE:-dev}
export TF_VAR_google_project=$GOOGLE_PROJECT
export TF_VAR_google_region=$GOOGLE_REGION
export TF_VAR_google_zone=$GOOGLE_ZONE
terraform init
terraform workspace new $ARGO_WORKSPACE || terraform workspace select $ARGO_WORKSPACE
terraform destroy -auto-approve
