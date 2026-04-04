output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = var.cloud == "aws" ? aws_eks_cluster.this[0].name : google_container_cluster.this[0].name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the Kubernetes cluster"
  value       = var.cloud == "aws" ? aws_eks_cluster.this[0].endpoint : google_container_cluster.this[0].endpoint
}

output "kubeconfig_command" {
  description = "Command to configure kubectl to talk to this cluster"
  value       = var.cloud == "aws" ? "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}" : "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}