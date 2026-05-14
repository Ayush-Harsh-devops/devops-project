#!/bin/bash
# ============================================================
# DevOps Monitoring Stack - Setup Script
# Author: Ayush Harsh
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo "============================================"
echo "  DevOps Monitoring Stack Setup"
echo "  Prometheus + Grafana + Alertmanager + Loki"
echo "============================================"

log "Checking dependencies..."
command -v docker >/dev/null 2>&1 || error "Docker not installed"
command -v docker-compose >/dev/null 2>&1 || error "Docker Compose not installed"

log "Starting monitoring stack..."
docker-compose up -d

log "Waiting for services to start (30s)..."
sleep 30

log "Running health checks..."

check_service() {
  local name=$1
  local url=$2
  if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|302"; then
    echo -e "  ${GREEN}✓${NC} $name is UP"
  else
    echo -e "  ${RED}✗${NC} $name is DOWN"
  fi
}

check_service "Prometheus"    "http://localhost:9090/-/healthy"
check_service "Grafana"       "http://localhost:3000/api/health"
check_service "Alertmanager"  "http://localhost:9093/-/healthy"
check_service "Node Exporter" "http://localhost:9100/metrics"

echo ""
echo "============================================"
echo "  Access URLs:"
echo "  Grafana:       http://localhost:3000"
echo "  Username:      admin"
echo "  Password:      DevOps@2024"
echo "  Prometheus:    http://localhost:9090"
echo "  Alertmanager:  http://localhost:9093"
echo "============================================"
