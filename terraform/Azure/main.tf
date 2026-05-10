terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {}

  default_tags = {
    project     = "traific"
    environment = var.environment
    managed_by  = "terraform"
  }
}
