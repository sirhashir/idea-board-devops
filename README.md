# Idea Board — AI-First DevOps Platform

A simple idea-sharing app, but the real work is the platform built around it. This project
is a full DevOps pipeline that automatically tests, builds, and deploys to multiple cloud
providers — with Claude AI making decisions at key points in the process.

## Live Demo

- **GCP:** http://34.41.102.80
- **AWS:** Pending account activation — infrastructure code is complete

---

## What's actually in this repo

The app itself is intentionally simple; a React frontend, a FastAPI backend, and a
PostgreSQL database. You can submit ideas and see them listed.\

The interesting part is everything around it:

- Docker containers for consistent builds across environments
- Terraform modules that deploy identically to AWS and GCP by changing one variable
- A GitHub Actions pipeline that goes from git push to live deployment automatically
- Claude AI integrated at three points in the pipeline to catch problems before they reach users

---

## Running it locally

You need Docker Desktop running. That's it.

```bash
git clone https://github.com/sirhashir/idea-board-devops.git
cd idea-board-devops
docker compose up --build
```

Open http://localhost:3000. Submit an idea. It should appear instantly.

To verify the backend is healthy:
```bash
curl http://localhost:8000/health
```

To stop:
```bash
docker compose down
```

To wipe the database and start fresh:
```bash
docker compose down -v
```

---

## How the pipeline works

Every push to main triggers this sequence:

**1. Tests** : pytest runs against the backend with a real PostgreSQL container.
The frontend build is verified. If anything fails, nothing gets deployed.

**2. Build** : Docker images are built and pushed to GitHub Container Registry,
tagged with the git commit SHA so every deployment is traceable.

**3. AI config** : if you triggered the pipeline with an environment goal
(like "cost-sensitive staging"), Claude translates that into actual Kubernetes
resource numbers i.e. replica counts, CPU limits, memory limits.

**4. Terraform** : provisions or updates the cloud infrastructure. Before applying,
Claude reviews the plan for security issues and unexpected costs.

**5. Deploy** : kubectl applies the manifests. Kubernetes does a rolling update
so there's no downtime.

**6. Health check** : Claude reads the pod logs, pod status, and health endpoint
response and decides if the deployment is healthy. If not, it rolls back automatically.

---

## The AI integration

There are three places Claude is used.

### Translating English to Kubernetes config

The pipeline accepts a plain-English goal and Claude
figures out the technical values. For example

```
"cost-sensitive staging"       → 1 replica, 50m CPU, 64Mi memory
"high-availability production" → 3 replicas, 200m CPU, 256Mi memory
```

This means developers can deploy to different environment types without needing
to understand Kubernetes internals.

### Reviewing Terraform plans

Before any infrastructure change goes live, Claude reads the terraform plan output
and checks for problems i.e. exposed databases, oversized instances, missing
encryption. It blocks the deployment if something is wrong.

This catches the kind of mistakes that are easy to miss when reviewing
large amount of code

### Post-deploy health analysis

This replaces just a basic generic health check.

Claude reads the full picture i.e. pod restart counts, recent logs, health endpoint
response and makes the same judgment call an experienced engineer would.
If something looks wrong, it rolls back and posts a plain-English explanation
of what happened.

---

## Cloud-agnostic design

The same three Terraform modules i.e. networking, kubernetes-cluster,
managed-database to deploy to either AWS or GCP. Each module has a `cloud`
variable. Set it to `"aws"` and you get EKS + RDS. Set it to `"gcp"` and
you get GKE + Cloud SQL.

What actually changes between the two deployments:

| Thing | AWS | GCP |
|-------|-----|-----|
| Kubernetes | EKS | GKE |
| Database | RDS | Cloud SQL |
| Node size | t3.small | e2-small |
| State storage | S3 | GCS |

Everything else including the app code, Docker images, Kubernetes manifests,
pipeline logic is identical.

Adding Azure would mean adding Azure resource blocks to each module
with `count = var.cloud == "azure" ? 1 : 0` and creating an
`environments/azure` folder.

---

## Deploying to a cloud

### Secrets needed in GitHub

```
GCP_SA_KEY            — service account JSON
GCP_PROJECT_ID        — your GCP project ID
ANTHROPIC_API_KEY     — Claude API key
DB_PASSWORD           — database password
AWS_ACCESS_KEY_ID     — AWS key (when account is active)
AWS_SECRET_ACCESS_KEY — AWS secret
```

### One-time setup

```bash
# GCP state bucket
gsutil mb gs://idea-board-tfstate-gcp

# AWS state bucket (when account activates)
aws s3api create-bucket --bucket idea-board-tfstate-aws --region us-east-1
```

### Running the pipeline

Go to Actions → Build and Deploy → Run workflow. Pick a cloud and an
environment goal. The pipeline handles the rest.

First run takes about 25 minutes, most of that is waiting for GKE/EKS
to provision. Subsequent runs skip infra that already exists and finish
in about 5 minutes.

---

## If something breaks

**Backend pods crashing:**
```bash
kubectl logs -l app=backend -n idea-board --tail=50
```
Usually a database connection issue. Check the DATABASE_URL secret has
the right value.

**Terraform state lock:**
```bash
gsutil rm gs://idea-board-tfstate-gcp/gcp/default.tflock
```

**kubectl can't reach the cluster:**
```bash
# GCP
gcloud container clusters get-credentials idea-board-gcp \
  --region us-central1 --project YOUR_PROJECT_ID

# AWS
aws eks update-kubeconfig --name idea-board-aws --region us-east-1
```

---

## AWS status

The AWS Terraform modules, environment config, and pipeline workflow are
all written and ready. Deployment is blocked on account activation as
new AWS accounts go through a verification period that can take up to 24 hours.

Once it activates, deploying to AWS is: add the two AWS secrets, create
the S3 state bucket, trigger the pipeline with cloud: aws. The same images
running on GCP deploy to EKS without any changes.
