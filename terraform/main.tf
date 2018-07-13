provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  count        = 2
  name         = "${lookup(var.instance_name, count.index)}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["reddit-app"]

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.priv_key)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  value = "appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgV0LOWkASUiBk1M5Sp0jNyZqMVMMRdDuxcqfST+YWW3G78sDg/+h+wLa6OE+ZMywfYwGJodmLFLPNl1ZFyXwMXqYIs1M6s0fRX6gNBShLcR/HbwOkMt6tXkFnhVkvkcVqJhYbbV5Dp3PAp7za3GHjnPZBUydGZ+acmoXKgv4uOtn67ye2qKqYtCY3TjEzXJd86kSbFXpcO8GSdWalULZEY6BoCOwMCWsimjQDQzB3zCTiJW6tcGLlPQk+pJTTjYp3hMNaVGVZZnK/0K4zq0qU1eo+TbS7NsJpBq7nTlRhMWUorkmWQDXpFKOj0d30PBuyBmjlEZbIsceCilCaiBXGw== appuser1 \nappuser2:ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgV0LOWkASUiBk1M5Sp0jNyZqMVMMRdDuxcqfST+YWW3G78sDg/+h+wLa6OE+ZMywfYwGJodmLFLPNl1ZFyXwMXqYIs1M6s0fRX6gNBShLcR/HbwOkMt6tXkFnhVkvkcVqJhYbbV5Dp3PAp7za3GHjnPZBUydGZ+acmoXKgv4uOtn67ye2qKqYtCY3TjEzXJd86kSbFXpcO8GSdWalULZEY6BoCOwMCWsimjQDQzB3zCTiJW6tcGLlPQk+pJTTjYp3hMNaVGVZZnK/0K4zq0qU1eo+TbS7NsJpBq7nTlRhMWUorkmWQDXpFKOj0d30PBuyBmjlEZbIsceCilCaiBXGw== appuser2 \nappuser3:ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgV0LOWkASUiBk1M5Sp0jNyZqMVMMRdDuxcqfST+YWW3G78sDg/+h+wLa6OE+ZMywfYwGJodmLFLPNl1ZFyXwMXqYIs1M6s0fRX6gNBShLcR/HbwOkMt6tXkFnhVkvkcVqJhYbbV5Dp3PAp7za3GHjnPZBUydGZ+acmoXKgv4uOtn67ye2qKqYtCY3TjEzXJd86kSbFXpcO8GSdWalULZEY6BoCOwMCWsimjQDQzB3zCTiJW6tcGLlPQk+pJTTjYp3hMNaVGVZZnK/0K4zq0qU1eo+TbS7NsJpBq7nTlRhMWUorkmWQDXpFKOj0d30PBuyBmjlEZbIsceCilCaiBXGw== appuser3"
}
