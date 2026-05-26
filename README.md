<div align="center">

# 🚀 DevOps Real-Time Projects
### by Ayush Harsh

![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins%20%7C%20GitHub%20Actions-blue?style=for-the-badge&logo=jenkins)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=for-the-badge&logo=amazonaws)
![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-E6522C?style=for-the-badge&logo=prometheus)

*Production-grade DevOps projects — CI/CD · IaC · Kubernetes · Monitoring · MLOps*

</div>

---

## 📂 Projects Overview

| # | Project | Stack | Status |
|---|---------|-------|--------|
| 01 | CI/CD Complete Pipeline | Jenkins · GitHub Actions · ArgoCD · EKS | ✅ Active |
| 02 | IaC Multi-Environment AWS | Terraform · VPC · EKS · RDS | ✅ Active |
| 03 | Kubernetes E-commerce App | Docker · Helm · ArgoCD · Prometheus | ✅ Active |
| 04 | Monitoring & Observability | Prometheus · Grafana · Alertmanager · Loki | ✅ Active |
| 05 | MLOps Pipeline on Kubernetes | MLflow · FastAPI · Docker · EKS | ✅ Active |

---

## 🔄 01 — CI/CD Complete Pipeline

> Jenkins + GitHub Actions + ArgoCD + AWS EKS

**Architecture:**
Code Push → GitHub Actions → Trivy Scan → SonarQube → Docker Build → ECR Push → ArgoCD → EKS

**Key Features:**
- Multi-stage Docker builds (deps → builder → production)
- Trivy vulnerability scanning (blocks on CRITICAL/HIGH)
- SonarQube quality gates
- GitOps deployment with ArgoCD (auto-sync + self-heal)
- Zero downtime rolling updates
- Slack notifications on success/failure
- Staging → Production approval gate

**Linux Commands to run locally:**
```bash
# Validate Jenkinsfile syntax
docker run --rm -v $(pwd):/workspace \
  jenkins/jenkins:lts \
  jenkins-jobs test /workspace/Jenkinsfile

# Test Docker build locally
docker build \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  -t devops-app:local .

# Run Trivy scan locally
trivy image --severity HIGH,CRITICAL devops-app:local

# Check image size
docker image inspect devops-app:local \
  --format='{{.Size}}' | \
  awk '{printf "Image size: %.2f MB\n", $1/1024/1024}'
```

---

## 🌍 02 — IaC Multi-Environment AWS Terraform

> Terraform Modules + AWS VPC/EKS/RDS + Remote State

**Architecture:**
environments/
├── dev/terraform.tfvars   → t3.medium · 1-3 nodes · db.t3.micro
└── prod/terraform.tfvars  → t3.large  · 2-10 nodes · db.t3.small · Multi-AZ

**Key Features:**
- Reusable modules: VPC · EKS · RDS
- Remote state: S3 + DynamoDB lock
- KMS encryption for EKS secrets + RDS
- VPC Flow Logs → CloudWatch
- Secrets Manager for DB credentials
- SPOT instances for dev, ON_DEMAND for prod

**Linux Commands to run locally:**
```bash
# Initialize Terraform
terraform init

# Create workspace
terraform workspace new dev

# Validate config
terraform validate

# Plan dev environment
terraform plan \
  -var-file=environments/dev/terraform.tfvars \
  -out=tfplan-dev

# Show plan summary
terraform show -json tfplan-dev | \
  jq '.resource_changes | group_by(.change.actions[]) | 
      map({action: .[0].change.actions[0], count: length})'

# Apply dev
terraform apply tfplan-dev

# Check state
terraform state list | grep -E "eks|rds|vpc"
```

---

## ☸️ 03 — Kubernetes E-commerce App

> Docker + Helm + ArgoCD + Prometheus + Grafana

**Architecture:**
ALB Ingress → Frontend(:80) → Backend(:3000) → PostgreSQL(:5432)
→ Redis(:6379

**Key Features:**
- 3-tier microservices with Docker Compose (local dev)
- Helm chart with Bitnami PostgreSQL + Redis dependencies
- HPA auto-scaling: 3→10 pods on CPU/Memory
- PodDisruptionBudget: min 2 pods always alive
- Topology spread across nodes
- Prometheus metrics scraping
- TLS via AWS ALB + ACM

**Linux Commands to run locally:**
```bash
# Start local dev stack
docker compose up -d

# Watch container health
watch -n 2 'docker compose ps'

# Check backend logs
docker compose logs -f backend | grep -E "ERROR|WARN|INFO"

# Lint Helm chart
helm lint k8s/helm/

# Dry-run Helm deploy
helm template ecommerce k8s/helm/ \
  -f k8s/helm/values.yaml \
  --debug | grep -E "kind:|name:"

# Deploy to K8s
helm upgrade --install ecommerce k8s/helm/ \
  -f k8s/helm/values.yaml \
  -n ecommerce \
  --create-namespace \
  --atomic \
  --timeout 5m

# Check rollout
kubectl rollout status deployment/ecommerce-app -n ecommerce
kubectl get hpa -n ecommerce
```

---

## 📊 04 — Monitoring & Observability Stack

> Prometheus + Grafana + Alertmanager + Loki + cAdvisor

**Architecture:**

Node Exporter → Prometheus → Grafana Dashboards
cAdvisor      ↗            → Alertmanager → Slack / Email
App metrics   ↗            → Loki (logs)

**Key Features:**
- Real-time metrics: CPU · Memory · Disk · Network
- 12 production alert rules (warning + critical)
- Slack + Email routing via Alertmanager
- Log aggregation: Loki + Promtail
- cAdvisor container metrics
- K8s DaemonSet node monitoring
- 15-day metric retention

**Linux Commands to run locally:**
```bash
# Start monitoring stack
chmod +x scripts/setup.sh && ./scripts/setup.sh

# Check all containers running
docker compose ps | awk '{print $1, $4}'

# Reload Prometheus config without restart
curl -X POST http://localhost:9090/-/reload

# Check active alerts
curl -s http://localhost:9093/api/v2/alerts | \
  jq '.[] | {alert: .labels.alertname, status: .status.state}'

# Query Prometheus directly
curl -s 'http://localhost:9090/api/v1/query?query=up' | \
  jq '.data.result[] | {job: .metric.job, up: .value[1]}'

# Tail Loki logs
curl -s \
  'http://localhost:3100/loki/api/v1/query_range?query={job="app"}&limit=20' | \
  jq '.data.result[].values[][1]'
```

---

## 🤖 05 — MLOps Pipeline on Kubernetes

> Python · MLflow · FastAPI · Docker · EKS

**Key Features:**
- House Price Prediction ML model (Scikit-learn)
- MLflow experiment tracking + model registry
- FastAPI REST API endpoint
- Dockerized + deployed on EKS
- HPA: 2→10 pods on CPU
- Prometheus model monitoring
- GitHub Actions CI/CD

**Linux Commands to run locally:**
```bash
# Train model
python train.py

# Check MLflow experiments
mlflow experiments list

# Run FastAPI locally
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Test prediction endpoint
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"sqft": 1500, "bedrooms": 3, "bathrooms": 2}'

# Build and push Docker image
docker build -t mlops-app:latest .
docker tag mlops-app:latest YOUR_ECR_URL/mlops-app:latest
docker push YOUR_ECR_URL/mlops-app:latest
```

---

## 🛠️ Tech Stack

| Category | Tools |
|----------|-------|
| CI/CD | Jenkins · GitHub Actions · ArgoCD |
| Containers | Docker · Kubernetes · Helm |
| Cloud/IaC | AWS EKS · EC2 · RDS · S3 · Terraform |
| Monitoring | Prometheus · Grafana · Alertmanager · Loki |
| Security | Trivy · SonarQube · KMS · Secrets Manager |
| ML | MLflow · FastAPI · Scikit-learn · Python |
| Databases | PostgreSQL · Redis |

---

## 👨‍💻 Author

**Ayush Harsh** — DevOps & Cloud Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Ayush--Harsh--devops-181717?style=flat&logo=github)](https://github.com/Ayush-Harsh-devops)
[![Email](https://img.shields.io/badge/Email-harsh4ayush85%40gmail.com-D14836?style=flat&logo=gmail)](mailto:harsh4ayush85@gmail.com)

---

<div align="center">
<i>Ayush Harsh</i>
</div>
