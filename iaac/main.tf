/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Configure the Google Cloud provider
provider "google" {
  project     = var.project_id
}

provider "google-beta" {
  project     = var.project_id
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

terraform {
  backend "gcs" {}
}

#Create a storage bucket for Dataflow Staging Files
resource "google_storage_bucket" "dataflow_staging_bucket" {
  name = "${var.dataflow_staging_bucket}-${random_id.bucket_id.hex}"
  location = var.bucket_location
}
# Grant privs to bucket for service account
resource "google_storage_bucket_iam_member" "dataflow_member" {
  bucket = google_storage_bucket.dataflow_staging_bucket.name
  role = "roles/storage.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

# Create a storage bucket for Uploaded Audio Files
resource "google_storage_bucket" "audio_uploads_bucket" {
  name = "${var.audio_uploads_bucket}-${random_id.bucket_id.hex}"
  location = var.bucket_location
}
# Grant privs to bucket for service account
resource "google_storage_bucket_iam_member" "audio_member" {
  bucket = google_storage_bucket.audio_uploads_bucket.name
  role = "roles/storage.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

# Create a storage bucket for Dataflow Flex template
resource "google_storage_bucket" "flextemplate_bucket" {
  name = "${var.flextemplate_bucket}-${random_id.bucket_id.hex}"
  location = var.bucket_location
}
# Grant privs to bucket for service account
resource "google_storage_bucket_iam_member" "flextemplate_member" {
  bucket = google_storage_bucket.flextemplate_bucket.name
  role = "roles/storage.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

# Create a storage bucket for Cloud Function Source files
resource "google_storage_bucket" "function_bucket" {
  name = "${var.function_bucket}-${random_id.bucket_id.hex}"
  location = var.bucket_location
}

# Firewall rules required by DataFlow 
resource "google_compute_firewall" "dataflow_firewall_rule" {
  name    = "dataflow-firewall"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_tags = ["dataflow"]
  target_tags = ["dataflow"]
}

# Create a BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = "test"
  description   = "This is a test description"
  location      = "US"
}

# Create Cloud Pub/Sub Topic
resource "google_pubsub_topic" "saf_topic" {
  name = var.saf_topic
}

# Creating and building a container image
module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"
  platform = "linux"
  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "builds submit --tag gcr.io/${var.project_id}/${var.image_name}:latest ../../dataflow-contact-center-speech-analysis/saf-longrun-job-dataflow"
}

# Create Flex Template
locals {
  jsonstring = jsonencode({

    "defaultEnvironment" : {},
    "image" : "gcr.io/${var.project_id}/${var.image_name}:latest",
    "sdkInfo" : {
      "language" : "PYTHON"
    }

  })
  depends_on = [
    module.gcloud
  ]
}

output "jsonstring" {
  value = local.jsonstring
}

resource "local_file" "jsonfile" {
  content  = local.jsonstring
  filename = "./template.json"
}

# Upload template.json to Cloud Storage
resource "google_storage_bucket_object" "template" {
  name   = "template.json"
  source = "./template.json"
  bucket = google_storage_bucket.flextemplate_bucket.name
}

# Run a Flex Template
resource "google_dataflow_flex_template_job" "big_data_job" {

  provider                = google-beta
  region                  = var.dataflow_region
  name                    = "${var.dataflow_name}-${random_id.bucket_id.hex}"
  container_spec_gcs_path = "gs://${google_storage_bucket.flextemplate_bucket.name}/template.json"
  parameters = {
    input_topic     = "projects/${var.project_id}/topics/${var.saf_topic}"
    temp_location   = "gs://${google_storage_bucket.dataflow_staging_bucket.name}/tmp"
    output_bigquery = "${var.dataset_id}.${var.table_id}"
    region          = var.dataflow_region
    service_account_email = var.service_account_email
  }
  depends_on = [
    google_storage_bucket_object.template,
    module.gcloud
  ]
}

# Deploy the Google Cloud Function
data "archive_file" "function_files" {
  type        = "zip"
  source_dir  = "../../dataflow-contact-center-speech-analysis/saf-longrun-job-func"
  output_path = "./function_zipfile/index.zip"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./function_zipfile/index.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  description = var.function_description
  runtime     = "nodejs16"
  region      = var.function_region

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "safLongRunJobFunc"
  service_account_email = var.service_account_email

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.audio_uploads_bucket.name
  }

  depends_on = [
    data.archive_file.function_files,
  ]

}

# Attributes (output) 
output "dataflow_staging_bucket" {
  value = google_storage_bucket.dataflow_staging_bucket.name
}

output "audio_uploads_bucket" {
  value = google_storage_bucket.audio_uploads_bucket.name
}