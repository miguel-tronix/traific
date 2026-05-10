resource "google_sql_database_instance" "traific" {
  name     = "traific-postgres"
  database_version = "POSTGRES_16"
  region   = var.gcp_region

  deletion_protection = false

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network_ref = google_compute_network.traific.id
      require_ssl     = true
    }

    backup_configuration {
      enabled                        = true
      start_time                    = "03:00"
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }
  }

  database_version    = "POSTGRES_16"
  depends_on          = [google_service_networking_connection.private]
}

resource "google_sql_database" "traific" {
  name     = "traific_db"
  instance = google_sql_database_instance.traific.name
}

resource "google_sql_user" "traific" {
  name     = "traific_admin"
  instance = google_sql_database_instance.traific.name
  password = var.db_password
}

resource "google_service_networking_connection" "private" {
  network                 = google_compute_network.traific.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["traific-peering-range"]
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}
