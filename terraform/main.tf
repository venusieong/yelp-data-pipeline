terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project = var.project_id
  region  = var.region
}

# Create a GCS bucket for data lake
resource "google_storage_bucket" "data_lake" {
  name     = var.gcs_bucket_name
  location = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }  
}

# Create BigQuery dataset for raw data
resource "google_bigquery_dataset" "raw_data" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}
