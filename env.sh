#!/bin/bash

export TF_VAR_project=YOUR-PROJECT-ID
export GCP_SERVICE_ACCOUNT_FILE=$(pwd)/gce_service_account.json
export GCE_ZONE=us-west1-a
export KUBECONFIG=$(pwd)/kubernetes/config.yml