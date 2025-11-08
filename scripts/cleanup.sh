#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ENVIRONMENT=$1

cleanup_environment() {
    local env=$1
    echo -e "${YELLOW}=== Cleaning up $env environment ===${NC}"
    
    local terraform_dir="$(dirname "$0")/../terraform/environments/$env"
    
    if [ -d "$terraform_dir" ]; then
        cd "$terraform_dir"
        
        echo -e "${GREEN}Destroying Terraform resources...${NC}"
        terraform destroy -auto-approve || echo -e "${YELLOW}Warning: Terraform destroy had issues${NC}"
        
        echo -e "${GREEN}Cleaning up Terraform state...${NC}"
        rm -f terraform.tfstate*
        rm -f *.tfplan
    fi
    
    # Force delete k3d cluster if it still exists
    local cluster_name="ktayl-$env"
    if k3d cluster list | grep -q "$cluster_name"; then
        echo -e "${GREEN}Force deleting k3d cluster $cluster_name...${NC}"
        k3d cluster delete "$cluster_name" || echo -e "${YELLOW}Warning: Could not delete cluster${NC}"
    fi
    
    echo -e "${GREEN}✓ $env environment cleaned up${NC}"
}

if [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}WARNING: This will destroy ALL environments!${NC}"
    read -p "Are you sure you want to continue? Type 'yes' to confirm: " -r
    
    if [ "$REPLY" == "yes" ]; then
        echo -e "${YELLOW}Destroying all environments...${NC}"
        
        for env in dev staging prod; do
            cleanup_environment "$env"
        done
        
        # Additional cleanup
        echo -e "${GREEN}Performing additional cleanup...${NC}"
        rm -rf "$(dirname "$0")/../terraform/environments/*/.terraform"
        rm -f "$(dirname "$0")/../terraform/environments/*/.terraform.lock.hcl"
        
        echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║     🧹 ALL ENVIRONMENTS CLEANED UP!              ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${YELLOW}Cleanup cancelled${NC}"
    fi
else
    # Validate environment
    if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
        echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
        echo -e "${YELLOW}Valid environments: dev, staging, prod${NC}"
        echo "Usage: $0 [dev|staging|prod]"
        echo "       $0              # Clean up all environments"
        exit 1
    fi
    
    echo -e "${RED}WARNING: This will destroy the $ENVIRONMENT environment!${NC}"
    read -p "Are you sure? Type 'yes' to confirm: " -r
    
    if [ "$REPLY" == "yes" ]; then
        cleanup_environment "$ENVIRONMENT"
        echo -e "${GREEN}✓ $ENVIRONMENT environment cleaned up successfully${NC}"
    else
        echo -e "${YELLOW}Cleanup cancelled${NC}"
    fi
fi