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

# Enable APIs
resource "google_project_service" "project" {
  for_each = var.service_ids
  project = var.project_id
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}