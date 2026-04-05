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

#AWS IAM ROLE FOR EKS CONTROL PLANE

data "aws_iam_policy_document" "eks_assume_role" {
  count = var.cloud == "aws" ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster" {
  count              = var.cloud == "aws" ? 1 : 0
  name               = "${var.cluster_name}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.cloud == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

#AWS EKS CLUSTER

resource "aws_eks_cluster" "this" {
  count    = var.cloud == "aws" ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

#AWS IAM ROLE FOR EKS WORKER NODES

data "aws_iam_policy_document" "node_assume_role" {
  count = var.cloud == "aws" ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_node" {
  count              = var.cloud == "aws" ? 1 : 0
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  count      = var.cloud == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node[0].name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  count      = var.cloud == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node[0].name
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  count      = var.cloud == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node[0].name
}

#AWS EKS NODE GROUP

resource "aws_eks_node_group" "this" {
  count           = var.cloud == "aws" ? 1 : 0
  cluster_name    = aws_eks_cluster.this[0].name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node[0].arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.node_type]

  scaling_config {
    desired_size = var.node_count
    min_size     = 1
    max_size     = var.node_count + 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy,
  ]

  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

#GCP GKE CLUSTER

resource "google_container_cluster" "this" {
  count                    = var.cloud == "gcp" ? 1 : 0
  name                     = var.cluster_name
  location                 = var.region
  network                  = var.vpc_id
  subnetwork               = var.subnet_ids[0]
  remove_default_node_pool = true
  initial_node_count       = 1
  project                  = var.project_id
  deletion_protection      = false

  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = 30
    machine_type = "e2-small"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_container_node_pool" "this" {
  count      = var.cloud == "gcp" ? 1 : 0
  name       = "${var.cluster_name}-nodes"
  cluster    = google_container_cluster.this[0].name
  location   = var.region
  node_count = var.node_count
  project    = var.project_id

  node_config {
    machine_type = "e2-small"
    disk_type    = "pd-standard"
    disk_size_gb = 30
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}