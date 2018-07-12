terraform {
  backend "gcs" {
    bucket = "storage-bucket-207421-2"
    prefix = "stage"
  }
}
