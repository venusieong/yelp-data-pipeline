variable "credentials" {
  description = "Path to the service account credentials JSON file"
  default = "terraform-service-account.json"
}


variable "project_id" {
  description = "The ID of the GCP project"
  default     = "yelpdatapipeline"
}

variable "region" {
  description = "The region for your resources"
  default     = "us-central1"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "yelp_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "yelp_gcp_bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}