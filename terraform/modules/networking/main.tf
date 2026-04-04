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

data "aws_availability_zones" "available" {
  count = var.cloud == "aws" ? 1 : 0 //if cloud is aws, then create this resource
  state = "available"
}

resource "aws_vpc" "this" {
  count             = var.cloud == "aws" ? 1 : 0
  cidr_block        = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "idea-board-vpc-${var.environment}"
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "aws_subnet" "public" {
  count             = var.cloud == "aws" ? 2 : 0 //creates 2 subnets
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index) //carving out 2 /24 subnets from /16 subnets 
  availability_zone = data.aws_availability_zones.available[0].names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "idea-board-subnet-${count.index}-${var.environment}"
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.cloud == "aws" ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name        = "idea-board-igw-${var.environment}"
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "aws_route_table" "public" {
  count  = var.cloud == "aws" ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name        = "idea-board-rt-${var.environment}"
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.cloud == "aws" ? 2 : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "google_compute_network" "this" {
  count                   = var.cloud == "gcp" ? 1 : 0
  name                    = "idea-board-vpc-${var.environment}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "public" {
  count         = var.cloud == "gcp" ? 2 : 0
  name          = "idea-board-subnet-${count.index}-${var.environment}"
  ip_cidr_range = cidrsubnet(var.cidr_block, 8, count.index)
  region        = var.region
  network       = google_compute_network.this[0].id
  project       = var.project_id
}