terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region

  default_labels = {
    project     = "traific"
    environment = var.environment
    managed_by  = "terraform"
  }
}
