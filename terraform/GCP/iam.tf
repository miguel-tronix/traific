resource "google_service_account" "traific" {
  account_id   = "traific-sa"
  display_name = "Traific Service Account"
}

resource "google_project_iam_member" "traific_workload" {
  project = var.gcp_project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.traific.email}"
}

resource "google_project_iam_member" "traific_cloudsql" {
  project = var.gcp_project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.traific.email}"
}

resource "google_project_iam_member" "traific_secret_manager" {
  project = var.gcp_project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.traific.email}"
}

resource "google_project_iam_member" "traific_kms" {
  project = var.gcp_project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:${google_service_account.traific.email}"
}
