variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "australia-southeast1"
}

variable "gcp_location" {
  description = "GCP Location (region or region/zone)"
  type        = string
  default     = "australia-southeast1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "traific-cluster"
}

variable "stream_processor_image" {
  description = "Docker image for the stream processor"
  type        = string
  default     = "traific/stream-processor:latest"
}

variable "api_image" {
  description = "Docker image for the FastAPI REST API"
  type        = string
  default     = "traific/api:latest"
}

variable "analytics_image" {
  description = "Docker image for the Analytics/Celery workers"
  type        = string
  default     = "traific/analytics:latest"
}

variable "db_password" {
  description = "Password for the Cloud SQL database"
  type        = string
  sensitive   = true
}
