output "db_host" {
  description = "Database host address"
  value       = var.cloud == "aws" ? aws_db_instance.this[0].address : google_sql_database_instance.this[0].public_ip_address
}

output "db_port" {
  description = "Database port"
  value       = 5432
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "db_username" {
  description = "Database username"
  value       = var.db_username
}

output "connection_string" {
  description = "Full PostgreSQL connection string for the backend"
  sensitive   = true
  value       = var.cloud == "aws" ? "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.this[0].address}:5432/${var.db_name}" : "postgresql://${var.db_username}:${var.db_password}@${google_sql_database_instance.this[0].public_ip_address}:5432/${var.db_name}"
}