provider "google" {
	version = "1.4.0"
	project ="${var.project}"
	region = "${var.region}"
}

module "storage-bucket" {
	source = "SweetOps/storage-bucket/google"
	version = "0.1.1"
	name = ["storage-bucket-207421-1", "storage-bucket-207421-2"]
}

output "storage-bucket" {
	value = "${module.storage-bucket.url}"
}

