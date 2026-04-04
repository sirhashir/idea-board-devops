output "vpc_id" {
  description = "The VPC or network ID"
  value       = var.cloud == "aws" ? aws_vpc.this[0].id : google_compute_network.this[0].name
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = var.cloud == "aws" ? aws_subnet.public[*].id : google_compute_subnetwork.public[*].name
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = var.cidr_block
}