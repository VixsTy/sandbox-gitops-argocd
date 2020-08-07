#!/bin/bash

set -e

BASEDIR=$PWD/$(dirname "$0")
cd $BASEDIR

############################################################################################
echo "checking prerequisite"
############################################################################################
if ! [ $(command -v gcloud) ]; then
  echo "error: This script need the gcloud binary."
  echo "You can follow the guide to install it : https://cloud.google.com/sdk/install"
  exit 1
fi

if ! [ $(command -v terraform) ]; then
  echo "error: This script need the terraform binary."
  echo "You can follow the guide to install it : https://learn.hashicorp.com/terraform/getting-started/install.html"
  exit 1
fi

export GOOGLE_REGION=${GOOGLE_REGION:-europe-west1}
export GOOGLE_ZONE=${GOOGLE_ZONE:-europe-west1-b}
export ARGO_WORKSPACE=${ARGO_WORKSPACE:-dev}
echo "GOOGLE_REGION: $GOOGLE_REGION;"
echo "GOOGLE_ZONE: $GOOGLE_ZONE;"
echo "GOOGLE_PROJECT: $GOOGLE_PROJECT;"
echo "GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
echo "ARGO_WORKSPACE: $ARGO_WORKSPACE;"
if [[ -z $GOOGLE_PROJECT || -z $GOOGLE_APPLICATION_CREDENTIALS ]]; then
    echo "error: missing environment configuration"
    exit 1
fi

############################################################################################
echo "Cluster creation with terraform"
############################################################################################
export TF_VAR_google_project=$GOOGLE_PROJECT
export TF_VAR_google_region=$GOOGLE_REGION
export TF_VAR_google_zone=$GOOGLE_ZONE
terraform init
terraform workspace new $ARGO_WORKSPACE || terraform workspace select $ARGO_WORKSPACE
# terraform plan
# exit 0
terraform apply -auto-approve
CLUSTER_NAME=`terraform output kubernetes_cluster_name`

############################################################################################
echo "Retrieve kubernetes credentials"
############################################################################################
if [ -f "$HOME/.config/gcloud/active_config" ]; then
  GCLOUD_OLD_CONF=$(cat $HOME/.config/gcloud/active_config)
  echo "saving old gcloud active config: $GCLOUD_OLD_CONF"
fi
gcloud config configurations create $CLUSTER_NAME || gcloud config configurations activate $CLUSTER_NAME
gcloud auth activate-service-account --project=$GOOGLE_PROJECT --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud container clusters get-credentials --project=$GOOGLE_PROJECT --zone=$GOOGLE_ZONE $CLUSTER_NAME
if [[ ! -z "$GCLOUD_OLD_CONF" ]]; then
  echo "restore old gcloud active config: $GCLOUD_OLD_CONF"
  gcloud config configurations activate $GCLOUD_OLD_CONF
  echo "delete temp gcloud config: $CLUSTER_NAME"
  gcloud config configurations delete --quiet $CLUSTER_NAME
fi

############################################################################################
echo "Deploy argocd"
############################################################################################
export K8S_NAMESPACE=${K8S_NAMESPACE:-"argocd"}
kubectl create namespace $K8S_NAMESPACE
kubectl config set-context --current --namespace=$K8S_NAMESPACE
kubectl apply -n $K8S_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user="$(gcloud config get-value account)"
