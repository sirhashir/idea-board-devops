terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

#AWS SECURITY GROUP

resource "aws_security_group" "rds" {
  count       = var.cloud == "aws" ? 1 : 0
  name        = "${var.environment}-rds-sg"
  description = "Allow PostgreSQL access from within the VPC only"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

#AWS RDS SUBNET GROUP

resource "aws_db_subnet_group" "this" {
  count      = var.cloud == "aws" ? 1 : 0
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

#AWS RDS INSTANCE

resource "aws_db_instance" "this" {
  count                  = var.cloud == "aws" ? 1 : 0
  identifier             = "${var.environment}-ideas-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = var.instance_class
  allocated_storage      = 20 //gb 
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  skip_final_snapshot    = true
  deletion_protection    = false
  publicly_accessible    = false

  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

#GCP CLOUD SQL INSTANCE

resource "google_sql_database_instance" "this" {
  count            = var.cloud == "gcp" ? 1 : 0
  name             = "${var.environment}-ideas-db"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  deletion_protection = false

  settings {
    tier = var.instance_class == "db.t3.micro" ? "db-f1-micro" : var.instance_class

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        value = "0.0.0.0/0"
        name  = "allow-all-temp"
      }
    }
  }
}

resource "google_sql_database" "this" {
  count    = var.cloud == "gcp" ? 1 : 0
  name     = var.db_name
  instance = google_sql_database_instance.this[0].name
  project  = var.project_id
}

resource "google_sql_user" "this" {
  count    = var.cloud == "gcp" ? 1 : 0
  name     = var.db_username
  instance = google_sql_database_instance.this[0].name
  password = var.db_password
  project  = var.project_id
}