module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"

  name                 = var.project_name
  random_project_id    = true
  org_id               = var.organization_id
  billing_account      = var.billing_account_id
  auto_create_network  = true
 
  # APIs Enabled
  activate_apis = [
      "dataflow.googleapis.com",
      "speech.googleapis.com",
      "cloudbuild.googleapis.com",
      "language.googleapis.com",
      "dlp.googleapis.com",
      "bigquery.googleapis.com",
      "cloudfunctions.googleapis.com",
      "monitoring.googleapis.com"
  ]
}

resource "google_compute_network" "default" {
  project                 = module.project-factory.project_id
  name                    = "default"
  auto_create_subnetworks = true
  mtu                     = 1460
}

resource "google_project_iam_member" "bigquery-binding" {
  project = module.project-factory.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "pubsub-binding" {
  project = module.project-factory.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "dataflow-binding" {
  project = module.project-factory.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "monitoring-binding" {
  project = module.project-factory.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "storage-binding" {
  project = module.project-factory.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "dlp-binding" {
  project = module.project-factory.project_id
  role    = "roles/dlp.user"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}