variable "zone" {
  description = "zone"
  default     = "europe-west1-b"
}

variable "db_disk_image" {
  description = "Disck image for reddit db"
  default     = "reddit-db-base"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
