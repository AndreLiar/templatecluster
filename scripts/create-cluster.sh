#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}Usage: $0 {dev|staging|prod}${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 dev      # Deploy development environment"
    echo "  $0 staging  # Deploy staging environment"
    echo "  $0 prod     # Deploy production environment"
    exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
    echo -e "${YELLOW}Valid environments: dev, staging, prod${NC}"
    exit 1
fi

# Check prerequisites
echo -e "${BLUE}=== Checking Prerequisites ===${NC}"

for cmd in k3d kubectl terraform helm; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed${NC}"
        echo "Install with: brew install $cmd"
        exit 1
    fi
    echo -e "${GREEN}✓ $cmd found${NC}"
done

# Set working directory
TERRAFORM_DIR="$(dirname "$0")/../terraform/environments/$ENVIRONMENT"
cd "$TERRAFORM_DIR"

# Determine cluster name based on environment
case "$ENVIRONMENT" in
  dev)
    CLUSTER_NAME="HDI-dev"
    ;;
  staging)
    CLUSTER_NAME="HDI-stage"
    ;;
  prod)
    CLUSTER_NAME="HDI-prod"
    ;;
esac

echo -e "${BLUE}=== Deploying $ENVIRONMENT Environment ===${NC}"
echo -e "${YELLOW}Working directory: $(pwd)${NC}"

# Initialize Terraform
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Check if cluster already exists
if k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
  echo -e "${YELLOW}Cluster ${CLUSTER_NAME} already exists, using single-stage deployment...${NC}"
  terraform apply -auto-approve
else
  echo -e "${YELLOW}Fresh deployment detected, using two-stage deployment...${NC}"

  # Stage 1: Create cluster first (establishes Kubernetes context)
  echo -e "${GREEN}Stage 1: Creating k3d cluster...${NC}"
  terraform apply -target=module.k3d_cluster -auto-approve

  # Stage 2: Deploy all modules to the cluster
  echo -e "${GREEN}Stage 2: Deploying all modules...${NC}"
  terraform apply -auto-approve
fi

# Wait for cluster to be fully ready
echo ""
echo -e "${BLUE}=== Waiting for Cluster to be Ready ===${NC}"
SCRIPT_DIR="$(dirname "$0")"
bash "$SCRIPT_DIR/wait-for-cluster.sh" "$CLUSTER_NAME" 600

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  $ENVIRONMENT Environment Deployed Successfully!  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"

# Show outputs
echo -e "${BLUE}=== Access Information ===${NC}"
terraform output -json | jq -r '
  .access_urls.value | to_entries[] | 
  "  \(.key | ascii_upcase): \(.value)"
'

echo ""
echo -e "${BLUE}=== Credentials ===${NC}"
echo -e "${YELLOW}Auto-generated secure credentials have been saved to:${NC}"
echo "  $(pwd)/.credentials"
echo ""
echo -e "${GREEN}View credentials:${NC}"
echo "  cat $(pwd)/.credentials"

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. View credentials: cat $(pwd)/.credentials"
echo "  2. Access services using the URLs above"
echo "  3. Deploy your applications via ArgoCD"
echo "  4. Monitor with Grafana dashboards"