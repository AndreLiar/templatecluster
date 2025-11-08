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

echo -e "${BLUE}=== Deploying $ENVIRONMENT Environment ===${NC}"
echo -e "${YELLOW}Working directory: $(pwd)${NC}"

# Initialize Terraform
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Plan deployment
echo -e "${GREEN}Planning deployment...${NC}"
terraform plan -out="$ENVIRONMENT.tfplan"

# Apply deployment
echo -e "${GREEN}Applying deployment...${NC}"
terraform apply "$ENVIRONMENT.tfplan"

# Cleanup plan file
rm -f "$ENVIRONMENT.tfplan"

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
echo -e "${BLUE}=== Default Credentials ===${NC}"
echo "  GRAFANA: admin / enterprise123"
echo "  ARGOCD: admin / Nightagent2025@"

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Access services using the URLs above"
echo "  2. Deploy your applications via ArgoCD"
echo "  3. Monitor with Grafana dashboards"