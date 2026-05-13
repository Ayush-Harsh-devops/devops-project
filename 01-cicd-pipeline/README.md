# 🚀 CI/CD Complete Pipeline — Production Grade

## 📌 Project Overview
End-to-end CI/CD pipeline using Jenkins + GitHub Actions + ArgoCD (GitOps) 
deploying a Node.js app to AWS EKS with zero downtime.

## 🏗️ Architecture
Developer Push → GitHub Actions (Security Scan + Tests)
↓
Jenkins (Build + SonarQube Quality Gate)
↓
Docker Build → Push to AWS ECR
↓
ArgoCD (GitOps) → Deploy to AWS EKS

## 🛠️ Tech Stack
| Tool | Purpose |
|------|---------|
| Jenkins | Build & Orchestration |
| GitHub Actions | Security Scan + Tests |
| SonarQube | Code Quality Gate |
| Docker | Containerization |
| AWS ECR | Container Registry |
| ArgoCD | GitOps Deployment |
| AWS EKS | Kubernetes Cluster |
| Trivy | Vulnerability Scanner |

## 📁 Project Structure
01-cicd-pipeline/
├── Jenkinsfile              # Jenkins Pipeline
├── Dockerfile               # Multi-stage Docker build
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions
├── argocd/
│   ├── application.yaml     # ArgoCD Application
│   └── deployment.yaml      # K8s Deployment + Service
└── README.md

## ⚡ Key Features
- ✅ Multi-stage Docker build (smaller image size)
- ✅ Trivy security scanning (blocks Critical/High CVEs)
- ✅ SonarQube quality gate (fails pipeline if code quality low)
- ✅ GitOps with ArgoCD (auto self-heal + auto sync)
- ✅ Zero downtime Rolling Update deployment
- ✅ Health checks + Readiness probes
- ✅ Non-root Docker user (security best practice)

## 🔐 Secrets Required

AWS_ACCESS_KEY_ID      → AWS credentials
AWS_SECRET_ACCESS_KEY  → AWS credentials
SONAR_TOKEN            → SonarCloud token

