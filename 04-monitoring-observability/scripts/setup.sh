#!/bin/bash
# ============================================================
# DevOps Monitoring Stack — Production Setup Script
# Author: Ayush Harsh
# Usage:
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh
# ============================================================

set -euo pipefail
IFS=$'\n\t'

# ── Colors ───────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Logging ──────────────────────────────────
log()     { echo -e "${GREEN}[INFO]${NC}  $(date '+%H:%M:%S') $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $(date '+%H:%M:%S') $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') $1"; exit 1; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ── Banner ───────────────────────────────────
echo -e "${BLUE}"
cat << 'EOF'
  ╔══════════════════════════════════════════╗
  ║   DevOps Monitoring Stack Setup          ║
  ║   Prometheus + Grafana + Alertmanager    ║
  ║   + Loki + Node Exporter + cAdvisor     ║
  ╚══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ── System Info ──────────────────────────────
section "System Info"
echo "  OS       : $(uname -s) $(uname -r)"
echo "  CPU      : $(nproc) cores"
echo "  RAM      : $(free -h | awk '/^Mem/{print $2}')"
echo "  Disk     : $(df -h . | awk 'NR==2{print $4}') free"
echo "  User     : $(whoami)@$(hostname)"
echo "  Date     : $(date '+%Y-%m-%d %H:%M:%S')"

# ── Check Dependencies ───────────────────────
section "Checking Dependencies"
check_cmd() {
  if command -v "$1" &>/dev/null; then
    log "$1 found: $(command -v $1)"
  else
    error "$1 not installed. Please install it first."
  fi
}
check_cmd docker
check_cmd docker-compose
check_cmd curl

# Docker running check
if ! docker info &>/dev/null; then
  error "Docker daemon is not running. Start it with: sudo systemctl start docker"
fi
log "Docker daemon is running"

# ── Create Secrets ───────────────────────────
section "Creating Secrets"
mkdir -p secrets

if [ ! -f secrets/grafana_password.txt ]; then
  GRAFANA_PASS=$(openssl rand -base64 16)
  echo "$GRAFANA_PASS" > secrets/grafana_password.txt
  chmod 600 secrets/grafana_password.txt
  log "Grafana password generated and saved to secrets/grafana_password.txt"
else
  warn "secrets/grafana_password.txt already exists — skipping"
fi

# ── Create Required Dirs ─────────────────────
section "Creating Directories"
mkdir -p prometheus alertmanager scripts
log "Directories ready"

# ── Start Stack ──────────────────────────────
section "Starting Monitoring Stack"
log "Pulling latest images..."
docker-compose pull 2>&1 | grep -E "Pulling|pulled|up to date" || true

log "Starting services..."
docker-compose up -d

# ── Wait for Services ─────────────────────────
section "Waiting for Services"
log "Waiting 30 seconds for services to start..."
for i in $(seq 30 -1 1); do
  printf "\r  ${YELLOW}[WAIT]${NC} %2ds remaining..." "$i"
  sleep 1
done
echo ""

# ── Health Checks ─────────────────────────────
section "Health Checks"
check_service() {
  local name="$1"
  local url="$2"
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")

  if echo "$http_code" | grep -qE "^(200|302|301)$"; then
    echo -e "  ${GREEN}✓${NC} $name is UP (HTTP $http_code)"
  else
    echo -e "  ${RED}✗${NC} $name is DOWN (HTTP $http_code)"
  fi
}

check_service "Prometheus"    "http://localhost:9090/-/healthy"
check_service "Grafana"       "http://localhost:3000/api/health"
check_service "Alertmanager"  "http://localhost:9093/-/healthy"
check_service "Node Exporter" "http://localhost:9100/metrics"
check_service "cAdvisor"      "http://localhost:8080/healthz"
check_service "Loki"          "http://localhost:3100/ready"

# ── Container Status ─────────────────────────
section "Container Status"
docker-compose ps

# ── Disk Usage ───────────────────────────────
section "Docker Volume Usage"
docker system df

# ── Access Info ──────────────────────────────
section "Access URLs"
GRAFANA_PASS=$(cat secrets/grafana_password.txt 2>/dev/null || echo "check secrets/grafana_password.txt")
echo ""
echo -e "  ${GREEN}Grafana${NC}        http://localhost:3000"
echo -e "  ${GREEN}Username${NC}       admin"
echo -e "  ${GREEN}Password${NC}       $GRAFANA_PASS"
echo ""
echo -e "  ${GREEN}Prometheus${NC}     http://localhost:9090"
echo -e "  ${GREEN}Alertmanager${NC}   http://localhost:9093"
echo -e "  ${GREEN}Node Exporter${NC}  http://localhost:9100"
echo -e "  ${GREEN}cAdvisor${NC}       http://localhost:8080"
echo -e "  ${GREEN}Loki${NC}           http://localhost:3100"
echo ""
log "Setup complete!"
