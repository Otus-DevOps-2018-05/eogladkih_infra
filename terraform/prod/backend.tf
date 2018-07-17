terraform {
  backend "gcs" {
    bucket = "storage-bucket-207421"
    prefix = "prod"
  }
}
