resource "google_compute_network" "traific" {
  name                    = "traific-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnet" "private" {
  name          = "traific-private-subnet"
  network       = google_compute_network.traific.name
  ip_cidr_range = var.vpc_cidr
  region        = var.gcp_region

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.0.0.0/20"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "traific-allow-internal"
  network = google_compute_network.traific.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.vpc_cidr]
}

resource "google_compute_router" "traific" {
  name    = "traific-router"
  network = google_compute_network.traific.name
  region  = var.gcp_region
}

resource "google_compute_nat_gateway" "traific" {
  name                               = "traific-nat"
  router                             = google_compute_router.traific.name
  region                             = var.gcp_region
  source_destination_matching_primary_vm = "ALL_SUBNETS"
}
