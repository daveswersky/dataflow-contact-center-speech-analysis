# module "project-factory" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 10.1"

#   name                 = var.project_name
#   random_project_id    = true
#   org_id               = "529148739755"
#   billing_account      = "010DEE-1A67CA-054E3A"
#   auto_create_network  = true
 
#   # APIs Enabled
#   activate_apis = [
#       "dataflow.googleapis.com",
#       "speech.googleapis.com",
#       "cloudbuild.googleapis.com",
#       "language.googleapis.com",
#       "dlp.googleapis.com",
#       "bigquery.googleapis.com",
#       "cloudfunctions.googleapis.com",
#       "monitoring.googleapis.com"
#   ]
# }

# Configure the Google Cloud provider
provider "google" {
  project     = var.project_id
}

provider "google-beta" {
  project     = var.project_id
}

resource "google_compute_network" "default" {
  project                 = var.project_id
  name                    = "default"
  auto_create_subnetworks = true
  mtu                     = 1460
}

