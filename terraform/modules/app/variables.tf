variable "zone" {
  description = "zone"
  default     = "europe-west1-b"
}

variable "app_disk_image" {
  description = "Disck image for reddit app"
  default     = "reddit-app-base"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
