resource "google_container_cluster" "traific" {
  name     = var.cluster_name
  location = var.gcp_location

  min_master_version = "1.29"

  network    = google_compute_network.traific.name
  subnetwork = google_compute_subnet.private.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_pool {
    name = "stateless"
    node_count = 2

    node_config {
      machine_type = "e2-medium"
      spot_config {
        spot = true
      }

      labels = {
        "workload-type" = "stateless"
      }
    }
  }

  node_pool {
    name = "redis"
    node_count = 1

    node_config {
      machine_type = "e2-medium"

      labels = {
        "workload-type" = "stateful"
        "component"      = "redis"
      }

      taints {
        key    = "workload"
        value  = "redis"
        effect = "NO_SCHEDULE"
      }
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  network_policy {
    enabled = true
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project}.svc.id.goog"
  }

  lifecycle {
    ignore_changes = [node_pool]
  }

  depends_on = [
    google_compute_network.traific,
    google_compute_subnet.private
  ]
}

data "google_client_config" "current" {}

data "google_container_cluster" "traific" {
  name     = google_container_cluster.traific.name
  location = google_container_cluster.traific.location
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.traific.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.traific.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}
