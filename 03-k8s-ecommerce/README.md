# ☸️ E-commerce App — Docker & Kubernetes Production Deploy

## 📌 Project Overview
Full 3-tier e-commerce application containerized with Docker
and deployed on AWS EKS using Helm + ArgoCD GitOps with
Prometheus & Grafana monitoring.

## 🏗️ Architecture

User → AWS ALB Ingress
↓
Frontend (React/Nginx) — 3 replicas
↓
Backend (Node.js API) — 3 replicas
↓
PostgreSQL (RDS) + Redis (Cache)
Monitoring: Prometheus → Grafana Dashboard
GitOps:     GitHub Push → ArgoCD → EKS Deploy

## 🛠️ Tech Stack
| Tool | Purpose |
|------|---------|
| Docker | Containerization |
| Docker Compose | Local Development |
| Kubernetes (EKS) | Production Orchestration |
| Helm | K8s Package Manager |
| ArgoCD | GitOps Deployment |
| Prometheus | Metrics Collection |
| Grafana | Monitoring Dashboard |
| AWS ALB | Load Balancer |
| HPA | Auto Scaling |

## 📁 Project Structure## 🛠️ Tech Stack

03-k8s-ecommerce/
├── docker/
│   ├── backend/Dockerfile     # Node.js multi-stage
│   ├── frontend/Dockerfile    # React + Nginx
│   └── docker-compose.yml     # Local dev setup
├── k8s/
│   ├── helm/
│   │   ├── Chart.yaml
│   │   └── values.yaml
│   └── argocd/
│       └── application.yaml
├── monitoring/
│   └── prometheus/
│       └── prometheus.yml
└── README.md

## ⚡ Key Features
- ✅ Multi-stage Docker builds (60% smaller images)
- ✅ Docker Compose for local development
- ✅ Helm charts for Kubernetes deployment
- ✅ ArgoCD GitOps (auto sync + self heal)
- ✅ HPA — Auto scaling (2 to 10 pods)
- ✅ Zero downtime Rolling Updates
- ✅ Prometheus + Grafana monitoring .
- ✅ AWS ALB Ingress Controller
- ✅ Health checks on all containers

## 🚀 Local Development
```bash
cd docker
docker-compose up -d
# Frontend: http://localhost:80
# Backend:  http://localhost:3000
# Grafana:  http://localhost:3001
```

## 👨‍💻 Author
**Ayush Harsh** | DevOps Engineer
