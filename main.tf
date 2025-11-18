terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = "vpc-sandbox"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "snet-sandbox-gke-portal"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.250.0.0/25"
}

resource "google_compute_instance" "vm" {
  name         = "demo2-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20
    }
  }


  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {} # Allocate external IP
  }
}