module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"

  name                 = var.project_name
  random_project_id    = true
  org_id               = "529148739755"
  billing_account      = "010DEE-1A67CA-054E3A"
  auto_create_network = true
 
  # APIs Enabled
  activate_apis = [
      "dataflow.googleapis.com",
      "speech.googleapis.com",
      "cloudbuild.googleapis.com",
      "language.googleapis.com",
      "dlp.googleapis.com",
  ]
}

resource "google_project_iam_member" "bigquery-binding" {
  project = module.project-factory.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "pubsub-binding" {
  project = module.project-factory.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}

resource "google_project_iam_member" "dataflow-binding" {
  project = module.project-factory.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}


