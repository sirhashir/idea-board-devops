locals {
  aws_host = var.cloud == "aws" ? aws_db_instance.this[0].address : ""
  gcp_host = var.cloud == "gcp" ? google_sql_database_instance.this[0].public_ip_address : ""
  db_host  = var.cloud == "aws" ? local.aws_host : local.gcp_host
}

output "db_host" {
  value = local.db_host
}

output "db_port" {
  value = 5432
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value = var.db_password
}

output "connection_string" {
  value = "postgresql://${var.db_username}:${var.db_password}@${local.db_host}:5432/${var.db_name}"
}