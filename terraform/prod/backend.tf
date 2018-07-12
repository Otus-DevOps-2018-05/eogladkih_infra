terraform {
  backend "gcs" {
    bucket = "storage-bucket-207421-1"
    prefix = "prod"
  }
}
