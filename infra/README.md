# GCP Gke IaaS

## Ressources

* GKE Cluster with node pool

## Pre-requisite

Create a service account to be used by terraform

```
$ gcloud init
$ gcloud auth login

# Enable APIs
$ gcloud services enable container.googleapis.com storage-component.googleapis.com

# Service account creation
$ gcloud iam service-accounts create terraform-dev

# Attribute role to service account
export GOOGLE_PROJECT=$(gcloud config get-value project)
$ gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member "serviceAccount:terraform-dev@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role "roles/container.admin"
$ gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member "serviceAccount:terraform-dev@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role "roles/compute.admin"
$ gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member "serviceAccount:terraform-dev@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role "roles/iam.serviceAccountUser"


# Retrieve credentials information to be use with terraform
$ gcloud iam service-accounts keys create terraform-dev.json --iam-account terraform-dev@$GOOGLE_PROJECT.iam.gserviceaccount.com
```

## quick start

### Create ressources

```
$ GOOGLE_PROJECT=$(gcloud config get-value project) \
  GOOGLE_REGION=$(gcloud config get-value compute/region) \
  GOOGLE_APPLICATION_CREDENTIALS=$PWD/terraform-dev.json \
  ./deploy.sh
```

### Destroy ressources

```
$ GOOGLE_APPLICATION_CREDENTIALS=$PWD/terraform-dev.json \
  ./destroy.sh
```
