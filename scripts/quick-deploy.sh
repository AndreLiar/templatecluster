#!/bin/bash

# One-Command Cluster Bootstrap
# Usage: ./quick-deploy.sh <project-name> <git-repo-url> [environment]

set -e

PROJECT_NAME=${1:-"myproject"}
GIT_REPO=${2:-"https://github.com/example/repo"}
ENVIRONMENT=${3:-"dev"}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Quick Deploy - K8s Cluster                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "Project: $PROJECT_NAME"
echo "Git Repo: $GIT_REPO"
echo "Environment: $ENVIRONMENT"
echo ""

# Check prerequisites
for cmd in k3d kubectl terraform helm; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed${NC}"
        exit 1
    fi
done

# Navigate to environment
ENV_DIR="terraform/environments/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${YELLOW}Environment $ENVIRONMENT not found. Using dev.${NC}"
    ENV_DIR="terraform/environments/dev"
fi

cd "$ENV_DIR"

# Check if tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
    
    cat > terraform.tfvars << EOF
git_repo_url  = "$GIT_REPO"
git_username  = "$GIT_USERNAME"
git_password  = "$GIT_PASSWORD"
argocd_admin_password = "Nightagent2025@"
EOF
fi

echo -e "${GREEN}=== Initializing Terraform ===${NC}"
terraform init

echo -e "${GREEN}=== Creating Cluster ===${NC}"
terraform apply -target=module.k3d_cluster -auto-approve

echo -e "${GREEN}=== Deploying Components ===${NC}"
terraform apply -auto-approve

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          🎉 Deployment Complete!                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Get ports based on environment
case $ENVIRONMENT in
    "dev")
        ARGOCD_PORT="30200"
        GRAFANA_PORT="30300"
        PROMETHEUS_PORT="30090"
        ;;
    "staging")
        ARGOCD_PORT="31200"
        GRAFANA_PORT="31300"
        PROMETHEUS_PORT="31090"
        ;;
    "prod")
        ARGOCD_PORT="32200"
        GRAFANA_PORT="32300"
        PROMETHEUS_PORT="32090"
        ;;
    *)
        ARGOCD_PORT="30200"
        GRAFANA_PORT="30300"
        PROMETHEUS_PORT="30090"
        ;;
esac

echo -e "${YELLOW}Access URLs:${NC}"
echo "  ArgoCD:     http://localhost:$ARGOCD_PORT"
echo "  Grafana:    http://localhost:$GRAFANA_PORT"
echo "  Prometheus: http://localhost:$PROMETHEUS_PORT"
echo ""
echo -e "${YELLOW}Credentials:${NC}"
echo "  ArgoCD:  admin / Nightagent2025@"
echo "  Grafana: admin / enterprise123"
echo ""
echo -e "${YELLOW}Cluster Context:${NC}"
echo "  kubectl config use-context k3d-$PROJECT_NAME-$ENVIRONMENT"
echo ""
