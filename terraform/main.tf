# Network setup
resource "google_compute_network" "k8s_network" {
  project                 = var.project
  name                    = var.vm_network
  auto_create_subnetworks = false
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "google_compute_subnetwork" "k8s_subnet" {
  name          = "${var.vm_network}-subnet"
  ip_cidr_range = "10.10.10.0/24"
  network       = var.vm_network
  region        = var.region
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  depends_on = [google_compute_network.k8s_network]
}

# Cloud NAT setup for egress trafic
resource "google_compute_router" "router" {
  project    = var.project
  name       = "nat-router"
  network    = var.vm_network
  region     = var.region
  depends_on = [google_compute_subnetwork.k8s_subnet]
}

resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on                         = [google_compute_subnetwork.k8s_subnet]
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "egress-rules" {
  project    = var.project
  name       = "k8s-fw-out-rules"
  network    = var.vm_network
  direction  = "EGRESS"
  depends_on = [google_compute_subnetwork.k8s_subnet]
  allow {
    protocol = "all"
  }
  priority = 1000
}

resource "google_compute_firewall" "internal-ingress-rules" {
  project    = var.project
  name       = "k8s-fw-internal-in-rules"
  network    = var.vm_network
  direction  = "INGRESS"
  depends_on = [google_compute_subnetwork.k8s_subnet]
  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.0.0/8"]
  priority      = 1000
}

resource "google_compute_firewall" "ssh-rules" {
  project    = var.project
  name       = "k8s-fw-ssh-rules"
  network    = var.vm_network
  direction  = "INGRESS"
  depends_on = [google_compute_subnetwork.k8s_subnet]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  priority      = 1000
}

# VM setup
resource "google_compute_instance" "k8s_infra" {
  name         = "${var.vm_name}-${count.index}"
  count        = var.vm_count
  machine_type = var.vm_type
  zone         = var.zone
  depends_on   = [google_compute_subnetwork.k8s_subnet]
  tags         = var.tags
  labels = {
    group = var.ansible_groups[count.index]
  }
  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.vm_disk_size
    }
  }
  scheduling {
    preemptible        = true
    automatic_restart  = false
    provisioning_model = "SPOT"
  }
  network_interface {
    network    = var.vm_network
    subnetwork = google_compute_subnetwork.k8s_subnet.name
  }

  metadata_startup_script = "apt-get update && apt-get upgrade -y"

  service_account {
    email  = var.account_id
    scopes = ["cloud-platform"]
  }
}
