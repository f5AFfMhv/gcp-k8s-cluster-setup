#!/bin/bash

# Project ID (not a name) in GCP
export TF_VAR_project=project-id-e7e85411
# Service account name for GCE VM management
export TF_VAR_account_id=k8s-vm-admin
# GCP region for network resources
export TF_VAR_region=europe-north1
# GCP zone for network resources
export TF_VAR_zone=europe-north1-a
# Your GCP account
export GCP_ACC=my.name@gmail.com
# Auth kind for GCP, leave as is
export GCP_AUTH_KIND=serviceaccount
# Location for generated SA key file
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/gce_service_account.json
# Zone where all VMs will be created
export GCE_ZONE=europe-north1-a
# Kubernetes config file location that will be downloaded from CP node
export KUBECONFIG=$(pwd)/kubernetes/config.yml