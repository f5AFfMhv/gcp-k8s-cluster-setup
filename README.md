# Introduction
This repository is intended to use as preparation for CKA (Certified Kubernetes Administration) exam. Terraform part will create 3 Ubuntu 22.04 VMs on Google Cloud Platform. Ansible part will prepare kubernetes cluster.

# Documentation
[Terraform google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
[Ansible google compute dynamic inventory](https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html)
[GCP IAP tunneling](https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/)

# Setup

## Components and versions
Due to issues I encountered following Linux Foundation CKA instructions, components and versions differs from official LABS.

|           |My setup     |CKA LABS     |
|-----------|-------------|-------------|
|OS         |Ubuntu 22.04 |Ubuntu 20.04 |
|Kubernetes |1.26.1       |1.24.1       |
|Runtime    |CRI-O        |containerd   |
|Calico     |3.25.0       |-            |

## Prerequisites
  - Terraform
  - Ansible
  - GCloud
  - Kubectl

Install numpy for increasing IAP TCP upload bandwith (optional)
```bash
$(gcloud info --format="value(basic.python_location)") -m pip install numpy
```

Create service account in GCP and grant `Compute OS Admin Login` role. Create and download service account json key.
[Check GCP IAP preaparation instructions](https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_2)

## Create infrastructure
Fill correct info in `env.sh` and source it.
```bash
source env.sh
```
cd to terraform directory, check `variables.tf` if any changes should be made according to your setup. Validate project and apply it.
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
> Terraform will create 3 VMs on the same subnet, there will be no external addresess assigned. To access internet from VMs CloudNAT will be used. To manage VMs from local machine GCP IAP will be used.
## Create Kubernetes cluster
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
# Start TCP IAP tunnel for kubernetes cluster (will need to provide user password to elevate priviliges)
ansible-playbook playbooks/start-iap-tunnel.yml -K
```
Ansible will:
* install required applications
* initialize k8s cluster with kubeadm
* apply calico manifests
* join 2 worker nodes to cluster
* copy kube config file to `kubectl` directory on localhost
* create IAP tunnel for kubectl communication with cluster API
* add CP node hostname to /etc/host file on localhost

## Access cluster with kubectl
`KUBECONFIG` env variable should point to downloaded config.yml in kubectl dir.
Test if cluster API can be accessed
```bash
cd kubectl
echo $KUBECONFIG # should be full path to config.yml
kubectl get nodes
```
