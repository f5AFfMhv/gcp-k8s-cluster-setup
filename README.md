# Introduction
This repository is intended to use as preparation for CKA (Certified Kubernetes Administration) exam. Terraform part will create 3 Ubuntu 22.04 VMs on Google Cloud Platform. Ansible part will prepare kubernetes cluster.

# Documentation
[Terraform google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
[Ansible google compute dynamic inventory](https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html)
[GCP IAP tunneling](https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/)

# Setup
## Prerequisites
  - Terraform
  - Ansible
  - GCloud
  - Kubectl

Create service account in GCP and grant `Compute OS Admin Login` role. Create and download service account json key.

## Create infrastructure
Fill correct info in `env.sh` and source it.
```bash
source env.sh
```
cd to terraform directory, check `variables.tf` if any changes should be made according to your setup. Validate project and apply it.
```bash
cd terraform
terraform validate
terraform plan
terraform apply
```
> Terraform will create 3 VMs on the same subnet, there will be no external addresess assigned. To access internet from VMs CloudNAT will be used. To manage VMs from local machine gcloud will be used as proxy.
# Create Kubernetes cluster
Change directory to `ansible`. Install python modules from requirements file.
```bash
pip install -r requirements.txt
```
Edit `gce.gcp.yml` and update `projects` field.
Validate ansible invetory and host connectivity.
```bash
ansible-inventory --list
ansible -m ping all
```
Run `site.yml` ansible playbook to setup kubernetes cluster
```bash
ansible-playbook site.yml
```