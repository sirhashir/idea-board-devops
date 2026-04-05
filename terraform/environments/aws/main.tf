terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "idea-board-tfstate-aws"
    key    = "aws/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "google" {
  project = "fake-project"
  region  = "us-central1"
}

provider "aws" {
  region = var.region
}

module "networking" {
  source      = "../../modules/networking"
  cloud       = "aws"
  environment = var.environment
  region      = var.region
  cidr_block  = var.vpc_cidr
}

module "cluster" {
  source       = "../../modules/kubernetes-cluster"
  cloud        = "aws"
  cluster_name = var.cluster_name
  environment  = var.environment
  node_count   = var.node_count
  node_type    = var.node_type
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.subnet_ids
  region       = var.region
}

module "database" {
  source         = "../../modules/managed-database"
  cloud          = "aws"
  environment    = var.environment
  db_name        = "ideas"
  db_username    = "ideas_user"
  db_password    = var.db_password
  instance_class = var.db_instance_class
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.subnet_ids
  vpc_cidr       = var.vpc_cidr
  region         = var.region
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