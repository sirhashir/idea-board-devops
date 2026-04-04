variable "cloud" {
  type        = string
  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "Cloud must be either 'aws' or 'gcp'."
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster"
}

variable "environment" {
  type        = string
  description = "Environment name e.g. production, staging"
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Number of worker nodes in the cluster"
}

variable "node_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for worker nodes. AWS: t3.small, GCP: e2-small"
}

variable "vpc_id" {
  type        = string
  description = "VPC or network ID from the networking module"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs from the networking module"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "GCP project ID - only required when cloud is gcp"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Cloud region"
}