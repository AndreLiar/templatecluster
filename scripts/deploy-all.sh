#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$0")"

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Enterprise Infrastructure Deployment         ║${NC}"
echo -e "${BLUE}║     Deploying All Environments                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

ENVIRONMENTS=("dev" "staging" "prod")

for env in "${ENVIRONMENTS[@]}"; do
    echo -e "${YELLOW}=== Deploying $env environment ===${NC}"
    
    if "$SCRIPT_DIR/create-cluster.sh" "$env"; then
        echo -e "${GREEN}✓ $env environment deployed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to deploy $env environment${NC}"
        exit 1
    fi
    
    echo ""
    sleep 5  # Brief pause between deployments
done

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     🎉 ALL ENVIRONMENTS DEPLOYED SUCCESSFULLY!   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}=== Environment Access Summary ===${NC}"
echo ""
echo -e "${YELLOW}DEV Environment (Branch: dev)${NC}"
echo "  • NGINX:      http://localhost:30080"
echo "  • Grafana:    http://localhost:30300 (admin/enterprise123)"
echo "  • Prometheus: http://localhost:30090"
echo "  • ArgoCD:     http://localhost:30200 (admin/Nightagent2025@)"
echo ""
echo -e "${YELLOW}STAGING Environment (Branch: staging)${NC}"
echo "  • NGINX:      http://localhost:31080"
echo "  • Grafana:    http://localhost:31300 (admin/enterprise123)"
echo "  • Prometheus: http://localhost:31090"
echo "  • ArgoCD:     http://localhost:31200 (admin/Nightagent2025@)"
echo ""
echo -e "${YELLOW}PRODUCTION Environment (Branch: main)${NC}"
echo "  • NGINX:      http://localhost:32080"
echo "  • Grafana:    http://localhost:32300 (admin/enterprise123)"
echo "  • Prometheus: http://localhost:32090"
echo "  • ArgoCD:     http://localhost:32200 (admin/Nightagent2025@)"
echo ""

echo -e "${BLUE}=== Next Steps ===${NC}"
echo "1. Verify all services are accessible using the URLs above"
echo "2. Configure your Git repository branches (dev, staging, main)"
echo "3. Push application manifests to trigger ArgoCD deployments"
echo "4. Monitor application health in Grafana dashboards"