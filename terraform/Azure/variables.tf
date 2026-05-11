variable "azure_location" {
  description = "Azure Region"
  type        = string
  default     = "australiaeast"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
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
  description = "Password for the Azure SQL database"
  type        = string
  sensitive   = true
}
