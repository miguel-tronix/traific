resource "google_storage_bucket" "datalake" {
  name          = "${var.gcp_project}-traific-datalake"
  location      = var.gcp_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_key.traific.self_link
  }
}

resource "google_kms_key_ring" "traific" {
  name     = "traific-keyring"
  location = var.gcp_region
}

resource "google_kms_key" "traific" {
  name            = "traific-key"
  key_ring        = google_kms_key_ring.traific.name
  rotation_period = "8640000s"

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

resource "google_storage_bucket_iam_member" "traific_invoker" {
  bucket = google_storage_bucket.datalake.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
