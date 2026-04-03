A full-stack DevOps case study built to demonstrate production-grade 
platform engineering. Ships a simple Idea Board app (React + FastAPI + 
PostgreSQL) as the deployment target, with the real focus being the 
intelligent platform built around it.

The platform features:
- Containerized services via Docker and Docker Compose for local dev
- Cloud-agnostic Terraform modules that deploy identically to AWS (EKS + 
  RDS) and GCP (GKE + Cloud SQL) by changing a single variable
- GitHub Actions CI/CD pipeline that builds, tests, and deploys on every push
- Claude AI integration at four pipeline stages: dynamic resource config 
  generation, Terraform plan security review, post-deploy health analysis 
  with automatic rollback, and PR comment-triggered preview environments
- Kubernetes manifests shared across both cloud providers with zero changes
