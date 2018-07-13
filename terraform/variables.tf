variable "project" {
  description = "Project ID"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "disk_image" {
  description = "Disk image"
}

variable "priv_key" {
  description = "private key for connection"
}

variable "zone" {
  description = "zone"
  default     = "europe-west1-b"
}

variable "instance_name" {
  default = {
    "0" = "reddit-app0"
    "1" = "reddit-app1"
  }
}
