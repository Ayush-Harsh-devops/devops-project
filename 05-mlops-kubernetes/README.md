# 🤖 MLOps Pipeline — ML Model on Kubernetes

End-to-end MLOps pipeline: Train → Track → Containerize → Deploy on AWS EKS .

## 🏗️ Architecture

Train Model (Python)
↓
MLflow Experiment Tracking
↓
Docker Image Build
↓
AWS ECR Push
↓ 
Kubernetes EKS Deploy
↓
FastAPI REST Endpoint
↓
Prometheus Monitoring

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| Python + Scikit-learn | ML Model Training |
| MLflow | Experiment Tracking |
| FastAPI | REST API |
| Docker | Containerization |
| AWS ECR | Image Registry |
| Kubernetes EKS | Deployment |
| HPA | Auto Scaling |
| Prometheus | Model Monitoring |
| GitHub Actions | CI/CD Pipeline |

## 🚀 Quick Start

### Local
```bash
pip install -r app/requirements.txt
python model/train.py
uvicorn app.main:app --reload
```

### API Test
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "area": 1500,
    "bedrooms": 3,
    "bathrooms": 2,
    "age": 5,
    "distance_km": 10,
    "floor": 3
  }'
```

## 👤 Author
**Ayush Harsh** — DevOps & Cloud Engineer
- harsh4ayush85@gmail.com
