terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "idea-board-tfstate-gcp"
    prefix = "gcp"
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "fake"
  secret_key                  = "fake"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source      = "../../modules/networking"
  cloud       = "gcp"
  environment = var.environment
  region      = var.region
  cidr_block  = var.vpc_cidr
  project_id  = var.project_id
}

module "cluster" {
  source       = "../../modules/kubernetes-cluster"
  cloud        = "gcp"
  cluster_name = var.cluster_name
  environment  = var.environment
  node_count   = var.node_count
  node_type    = var.node_type
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.subnet_ids
  region       = var.region
  project_id   = var.project_id
}

module "database" {
  source         = "../../modules/managed-database"
  cloud          = "gcp"
  environment    = var.environment
  db_name        = "ideas"
  db_username    = "ideas_user"
  db_password    = var.db_password
  instance_class = var.db_instance_class
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.subnet_ids
  vpc_cidr       = var.vpc_cidr
  region         = var.region
  project_id     = var.project_id
}

output "kubeconfig_command" {
  value = module.cluster.kubeconfig_command
}

output "db_connection_string" {
  value     = module.database.connection_string
  sensitive = true
}

output "cluster_name" {
  value = module.cluster.cluster_name
}