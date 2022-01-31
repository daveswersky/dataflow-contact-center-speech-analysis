
resource "google_service_account" "service_account" {
  account_id   = "serviceAccount:project-service-account@${var.project_id}.iam.gserviceaccount.com"
  display_name = "Project Service Account"
}

resource "google_project_iam_member" "bigquery-binding" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_service_account.service_account.email
}

resource "google_project_iam_member" "pubsub-binding" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = google_service_account.service_account.email
}

resource "google_project_iam_member" "dataflow-binding" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = google_service_account.service_account.email
}

resource "google_project_iam_member" "monitoring-binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.service_account.email
}

resource "google_project_iam_member" "storage-binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = google_service_account.service_account.email
}

resource "google_project_iam_member" "dlp-binding" {
  project = module.project-factory.project_id
  role    = "roles/dlp.user"
  member  = google_service_account.service_account.email
}