
variable "region" {
  description = "GCP region"
}

variable "zone" {
  description = "GCP zone"
}

variable "account_id" {
  description = "GCP service account ID"
}

variable "project" {
  description = "GCP project ID"
}

variable "tags" {
  default     = ["k8s"]
  description = "VM tags"
}

variable "ansible_groups" {
  default     = ["cp", "cp", "worker", "worker", "worker", "lb"]
  description = "Label value for ansible groups"
}

variable "vm_name" {
  default     = "k8s"
  description = "VM name"
}

variable "vm_type" {
  default     = "e2-medium"
  description = "VM type"
}

variable "vm_image" {
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
  description = "VM image"
}

variable "vm_network" {
  default     = "k8s-network"
  description = "VM network"
}

variable "vm_count" {
  default     = 6
  description = "VM count"
}

variable "vm_disk_size" {
  default     = 20
  description = "VM disk size"
}

output "instance_id" {
  value = google_compute_instance.k8s_infra[*].id
}
