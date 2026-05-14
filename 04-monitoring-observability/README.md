# 📊 DevOps Monitoring & Observability Stack

Production-grade monitoring stack with Prometheus, Grafana, Alertmanager, and Loki — deployed on Kubernetes (AWS EKS)

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| Prometheus | Metrics collection |
| Grafana | Dashboards |
| Alertmanager | Slack + Email alerts |
| Loki | Log aggregation |
| Node Exporter | CPU, RAM, Disk metrics |
| AWS EKS | Kubernetes cluster |

## 📁 Project Structure

04-monitoring-observability/
├── prometheus/          → Scrape config + Alert rules
├── alertmanager/        → Slack + Email routing
├── grafana/dashboards/  → Custom dashboard JSON
├── k8s/                 → Kubernetes deployment
├── scripts/             → Setup script
└── docker-compose.yml   → Local testing

## 🚀 Quick Start

Local (Docker):
docker-compose up -d

Kubernetes (EKS):
kubectl apply -f k8s/monitoring-stack.yml

## Access

- Grafana   → http://localhost:3000  (admin / DevOps@2024)
- Prometheus → http://localhost:9090
- Alertmanager → http://localhost:9093

## 👤 Author

Ayush Harsh — | DevOps & Cloud Engineer |
Email: harsh4ayush85@gmail.com
GitHub: https://github.com/Ayush-Harsh-devops
