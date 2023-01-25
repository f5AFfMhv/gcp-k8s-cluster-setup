
variable "region" {
  default     = "us-west1"
  description = "GCP region"
}

variable "zone" {
  default     = "us-west1-a"
  description = "GCP zone"
}

variable "account_id" {
  description = "Service account exported as env var $TF_VAR_account_id"
}

variable "project" {
  description = "Service account exported as env var $TF_VAR_project"
}

variable "tags" {
  default     = ["k8s"]
  description = "VM tags"
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
  default     = "debian-cloud/debian-11"
  description = "VM image"
}

variable "vm_network" {
  default     = "default"
  description = "VM network"
}

variable "vm_count" {
  default     = 3
  description = "VM count"
}

variable "vm_disk_size" {
  default     = 20
  description = "VM disk size"
}

output "instance_id" {
  value = google_compute_instance.k8s_infra[*].id
}