# Introduction

This repository is intended to use as preparation for CKA (Certified Kubernetes Administration) exam. Terraform part will create 6 Ubuntu 22.04 VMs on Google Cloud Platform. Ansible part will prepare kubernetes cluster.

# Documentation

[Terraform google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)  
[Ansible google compute dynamic inventory](https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html)  
[GCP IAP tunneling](https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/)

# Setup

## Components and versions

Due to issues I encountered following Linux Foundation CKA instructions, components and versions differs from official LABS.

|            | My setup     | CKA LABS     |
| ---------- | ------------ | ------------ |
| OS         | Ubuntu 22.04 | Ubuntu 20.04 |
| Kubernetes | 1.26.1       | 1.24.1       |
| Runtime    | CRI-O        | containerd   |
| Calico     | 3.25.0       | ?            |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [GCloud](https://cloud.google.com/sdk/docs/install)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

Install numpy for increased IAP TCP upload bandwith (optional)

```bash
$(gcloud info --format="value(basic.python_location)") -m pip install numpy
```

- Go to [Google Cloud console](https://console.cloud.google.com).
- Create new project.
- Enable `Compute Engine API`
- Authenticate with gcloud, run `gcloud auth login` and follow the instructions.
- Set gcloud default project and zone:

```bash
gcloud config set project <MY_PROJECT>
gcloud config set compute/zone us-west1-a
```

- [Create service account](https://developers.google.com/identity/protocols/oauth2/service-account#creatinganaccount) in GCP and grant `Owner` role.
- [Create and download service account json key](https://cloud.google.com/iam/docs/keys-create-delete#creating). Key file location needs be defined in `env.sh`.
- [Check GCP IAP preaparation instructions](https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_2).

## Create infrastructure

Fill correct info in `env.sh` and source it.

```bash
source env.sh
```

Change to terraform directory, check `variables.tf` if any changes should be made according to your setup. Validate project and apply it.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform will create 6 Ubuntu VMs on the same subnet. There will be no external IP addresess assigned for them. CloudNAT will be used to access internet from VMs. To manage VMs GCP IAP tunneling will be used.

## Create Kubernetes cluster

Change directory to `ansible`. Install python modules from requirements file.

```bash
pip install -r requirements.txt
```

Edit `gce.gcp.yml` and update `projects` field.
Validate ansible inventory and host connectivity.

```bash
ansible-inventory --list
ansible -m ping all
```

Run `site.yml` ansible playbook to setup kubernetes cluster

```bash
# You will need to provide user password to elevate priviliges for starting IAP tunnel
ansible-playbook site.yml -K
```

Ansible will:

- install required applications
- setup NFS server
- initialize k8s cluster with kubeadm
- apply calico manifests
- join 2 worker nodes to cluster
- join 3 controller plain nodes to cluster
- setup HAproxy for kubernetes API
- copy kube config file to `kubernetes` directory on localhost
- create IAP tunnel for kubectl communication with cluster API
- add load balancer node hostname to `/etc/hosts` file on localhost

## Access cluster with kubectl

`KUBECONFIG` env variable should point to downloaded config.yml in `kubernetes` dir.
Test if cluster API can be accessed.

```bash
cd kubernetes
echo $KUBECONFIG # should be full path to config.yml
kubectl get nodes
```

## Destroy infrastructure

Don't forget to destroy infrastructure after you're done.

```bash
cd terraform
terraform destroy
```
