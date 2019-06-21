terraform {
  backend "remote" {
    organization = "<<YOUR TERRAFORM ENTERPRISE ORGANIZATION>>"

    workspaces {
      name = "<<ORGANIZATION>>"
    }
  }
}

provider "google" {
  project     = "<<GCP PROJECT TO USE>>"
  region      = "us-east1"
  version = "=  2.5.1"
}

resource "google_compute_network" "multicloud" {
  name                    = "multicloud"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "internal" {
  name          = "internal"
  ip_cidr_range = "10.2.2.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.multicloud.self_link}"
}

resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.2.4.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.multicloud.self_link}"
}

resource "google_compute_firewall" "allow-http" {
  name    = "multicloud-allow-http"
  network = "${google_compute_network.multicloud.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["test-server"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "multicloud-allow-ssh"
  network = "${google_compute_network.multicloud.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["test-server"]
}

resource "google_compute_instance" "testserver1" {
  name         = "gcp-webserver-1"
  machine_type = "n1-standard-1"
  zone         = "us-east1-c"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "${google_compute_network.multicloud.self_link}"
    subnetwork = "${google_compute_subnetwork.public.self_link}"

    access_config {
      // Ephemeral IP
    }
  }

  # metadata_startup_script = "sudo yum  update && sudo yum  install httpd -y && echo '<!doctype html><html><body><h1>Hello Multicloud 2019 from GCP!</h1></body></html>' | sudo tee /var/www/html/index.html && sudo systemctl start httpd"

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["test-server"]

  metadata = {
    sshKeys = "multicloud:<<SSH KEY TO USE>>"
  }

}
