#!/bin/bash

# Source env variables
source env.sh

# Authenticate with Google Cloud
gcloud auth login ${GCP_ACC}

# Set the Google Cloud project
gcloud config set project ${TF_VAR_project}

# Create a service account
gcloud iam service-accounts create ${TF_VAR_account_id} \
  --description="Kubernetes VM Admin Service Account" \
  --display-name="${TF_VAR_account_id}"

# Grant Compute OS Admin Login role to the service account
gcloud projects add-iam-policy-binding ${TF_VAR_project} \
  --role roles/compute.admin \
  --role roles/iam.serviceAccountUser \
  --member=serviceAccount:${TF_VAR_account_id}@${TF_VAR_project}.iam.gserviceaccount.com

# Grant sa user role for your account 
gcloud projects add-iam-policy-binding ${TF_VAR_project} \
  --role roles/iam.serviceAccountUser \
  --member=user:${GCP_ACC}

# Generate and save the service account key as a JSON file locally
gcloud iam service-accounts keys create ${GCP_SERVICE_ACCOUNT_FILE} \
  --iam-account ${TF_VAR_account_id}@${TF_VAR_project}.iam.gserviceaccount.com
