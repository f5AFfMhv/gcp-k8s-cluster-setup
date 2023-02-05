#!/bin/bash
export TF_VAR_project=YOUR-PROJECT-ID
export TF_VAR_account_id=YOUR-SERVICE-ACCOUNT-ID
export GCP_AUTH_KIND=serviceaccount
export GCP_SERVICE_ACCOUNT_FILE=/path/to/file/gce_service_account.json
export GCE_ZONE=us-west1-a