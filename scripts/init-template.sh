#!/bin/bash

# K8s Cluster Template Initialization Script
# This script helps you quickly set up a new project from this template

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   K8s Cluster Template Initialization           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Collect information
read -p "Enter your project name (e.g., myapp): " PROJECT_NAME
read -p "Enter Git repository URL: " GIT_REPO_URL
read -p "Enter Git username: " GIT_USERNAME
read -sp "Enter Git password/token: " GIT_PASSWORD
echo ""
read -p "Enter ArgoCD admin password: " ARGOCD_PASSWORD

if [ -z "$PROJECT_NAME" ] || [ -z "$GIT_REPO_URL" ] || [ -z "$GIT_USERNAME" ] || [ -z "$GIT_PASSWORD" ]; then
    echo -e "${RED}Error: All fields are required${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== Configuration Summary ===${NC}"
echo "Project Name: $PROJECT_NAME"
echo "Git Repository: $GIT_REPO_URL"
echo "Git Username: $GIT_USERNAME"
echo ""

read -p "Proceed with initialization? (y/n): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Initialization cancelled"
    exit 0
fi

echo ""
echo -e "${BLUE}=== Updating Configuration Files ===${NC}"

# Update cluster names in main.tf files
for env in dev staging prod; do
    if [ -f "terraform/environments/$env/main.tf" ]; then
        echo -e "${GREEN}✓ Updating $env/main.tf${NC}"
        sed -i.bak "s/cluster_name = \"ktayl-\${local.environment}\"/cluster_name = \"$PROJECT_NAME-\${local.environment}\"/" "terraform/environments/$env/main.tf"
        rm "terraform/environments/$env/main.tf.bak"
    fi
done

# Create .tfvars files from examples or update existing ones
for env in dev staging prod; do
    TFVARS_FILE="terraform/environments/$env/terraform.tfvars"
    
    if [ -f "$TFVARS_FILE" ]; then
        echo -e "${GREEN}✓ Updating $env/terraform.tfvars${NC}"
        
        # Update git repository URL
        sed -i.bak "s|git_repo_url.*=.*|git_repo_url = \"$GIT_REPO_URL\"|" "$TFVARS_FILE"
        
        # Update git username
        sed -i.bak "s|git_username.*=.*|git_username = \"$GIT_USERNAME\"|" "$TFVARS_FILE"
        
        # Update git password
        sed -i.bak "s|git_password.*=.*|git_password = \"$GIT_PASSWORD\"|" "$TFVARS_FILE"
        
        # Update ArgoCD password if provided
        if [ -n "$ARGOCD_PASSWORD" ]; then
            sed -i.bak "s|argocd_admin_password.*=.*|argocd_admin_password = \"$ARGOCD_PASSWORD\"|" "$TFVARS_FILE"
        fi
        
        rm "$TFVARS_FILE.bak"
    fi
done

echo ""
echo -e "${BLUE}=== Creating Example Files ===${NC}"

# Create .tfvars.example files (without sensitive data)
for env in dev staging prod; do
    EXAMPLE_FILE="terraform/environments/$env/terraform.tfvars.example"
    
    cat > "$EXAMPLE_FILE" << EOF
# Git Repository Configuration
git_repo_url  = "$GIT_REPO_URL"
git_username  = "your-git-username"
git_password  = "your-git-token-or-password"

# ArgoCD Configuration
argocd_admin_password = "your-secure-password"
EOF
    
    echo -e "${GREEN}✓ Created $env/terraform.tfvars.example${NC}"
done

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo -e "${GREEN}✓ Creating .gitignore${NC}"
    cat > ".gitignore" << 'EOF'
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
.terraform.lock.hcl
*.tfplan

# Sensitive files
**/terraform.tfvars
!**/terraform.tfvars.example

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
EOF
fi

# Update README with project name
if [ -f "README.md" ]; then
    echo -e "${GREEN}✓ Updating README.md${NC}"
    sed -i.bak "s/KtaylBusiness/$PROJECT_NAME/g" "README.md"
    sed -i.bak "s/ktayl/$PROJECT_NAME/g" "README.md"
    rm "README.md.bak"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        🎉 Initialization Complete!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review the generated configuration files"
echo "2. Deploy your first environment:"
echo ""
echo -e "${BLUE}   cd terraform/environments/dev${NC}"
echo -e "${BLUE}   terraform init${NC}"
echo -e "${BLUE}   terraform apply -target=module.k3d_cluster -auto-approve${NC}"
echo -e "${BLUE}   terraform apply -auto-approve${NC}"
echo ""
echo "3. Or use the convenience script:"
echo -e "${BLUE}   ./scripts/create-cluster.sh dev${NC}"
echo ""
echo -e "${YELLOW}Access URLs (after deployment):${NC}"
echo "  Dev ArgoCD:       http://localhost:30200"
echo "  Dev Grafana:      http://localhost:30300"
echo "  Dev Prometheus:   http://localhost:30090"
echo ""
echo "  Staging ArgoCD:   http://localhost:31200"
echo "  Staging Grafana:  http://localhost:31300"
echo ""
echo -e "${YELLOW}Credentials:${NC}"
echo "  ArgoCD:  admin / $ARGOCD_PASSWORD"
echo "  Grafana: admin / enterprise123"
echo ""
