variable "project_id" {
    type = string
    default = "speech-analysis"
}

variable "service_ids" {
    type = list(string)
    default = ["dataflow.googleapis.com",
      "speech.googleapis.com",
      "cloudbuild.googleapis.com",
      "language.googleapis.com",
      "dlp.googleapis.com",
      "bigquery.googleapis.com",
      "cloudfunctions.googleapis.com",
      "monitoring.googleapis.com",
      "cloudtrace.googleapis.com"]
}