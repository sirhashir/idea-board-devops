variable "cloud" {
  type = string
  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "Cloud must be either 'aws' or 'gcp'."
  }
}

variable "environment" {
  type        = string
  description = "Environment name e.g. production, staging"
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
  default     = "ideas"
}

variable "db_username" {
  type        = string
  description = "Database master username"
  default     = "ideas_user"
}

variable "db_password" {
  type        = string
  sensitive   = true //so that password remains hidden
  description = "Database master password - never hardcode this"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance size. AWS: db.t3.micro, GCP: db-f1-micro"
}

variable "vpc_id" {
  type        = string
  description = "VPC or network ID from the networking module"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs from the networking module"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block of the VPC for security group rules"
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