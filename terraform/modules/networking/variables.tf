variable "cloud" {
  type        = string
  description = "Cloud provider to use: aws or gcp"

  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "Cloud must be either 'aws' or 'gcp'."
  }
}

variable "environment" {
  type        = string
  description = "Environment name e.g. production, staging"
}

variable "region" {
  type        = string
  description = "Cloud region"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "GCP project ID - only required when cloud is gcp"
}