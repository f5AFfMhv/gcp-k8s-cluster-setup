resource "google_compute_instance" "k8s_infra" {
  name         = "${var.vm_name}-${count.index}"
  count        = var.vm_count
  machine_type = var.vm_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.vm_disk_size
    }
  }

  network_interface {
    network = var.vm_network
  }

  metadata_startup_script = "apt-get update && apt-get upgrade -y"

  service_account {
    email  = var.account_id
    scopes = ["cloud-platform"]
  }
}