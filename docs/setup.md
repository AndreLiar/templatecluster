# 🚀 Enterprise Infrastructure Setup Guide

This guide will help you deploy a complete enterprise-grade Kubernetes infrastructure with GitOps workflow.

## 📋 Prerequisites

### Required Tools
```bash
# Install all required tools
brew install k3d kubectl terraform helm jq

# Verify installations
k3d version
kubectl version --client
terraform version
helm version
```

### GitHub Repository Setup
1. Fork or clone the repository
2. Create branches: `dev`, `staging`, `main`
3. Generate a Personal Access Token (PAT)
4. Update `terraform.tfvars` with your Git credentials

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Enterprise Infrastructure                │
├─────────────────┬─────────────────┬─────────────────────────┤
│   DEV CLUSTER   │ STAGING CLUSTER │   PROD CLUSTER          │
│                 │                 │                         │
│ Port Range:     │ Port Range:     │ Port Range:            │
│ 30xxx           │ 31xxx           │ 32xxx                  │
│                 │                 │                         │
│ Git Branch:     │ Git Branch:     │ Git Branch:            │
│ dev             │ staging         │ main                   │
├─────────────────┼─────────────────┼─────────────────────────┤
│ • NGINX Ingress │ • NGINX Ingress │ • NGINX Ingress        │
│ • Prometheus    │ • Prometheus    │ • Prometheus           │
│ • Grafana       │ • Grafana       │ • Grafana              │
│ • ArgoCD        │ • ArgoCD        │ • ArgoCD               │
│ • AlertManager  │ • AlertManager  │ • AlertManager         │
│ • Sealed Secrets│ • Sealed Secrets│ • Sealed Secrets       │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 🚀 Quick Start

### Option 1: Deploy Single Environment (Recommended for Testing)
```bash
# Deploy development environment
./scripts/create-cluster.sh dev

# Deploy staging environment  
./scripts/create-cluster.sh staging

# Deploy production environment
./scripts/create-cluster.sh prod
```

### Option 2: Deploy All Environments
```bash
# Deploy all three environments at once
./scripts/deploy-all.sh
```

## 📊 Environment Details

### Development Environment
- **Cluster Name**: `ktayl-dev`
- **Git Branch**: `dev`
- **Port Range**: `30xxx`

| Service | URL | Credentials |
|---------|-----|-------------|
| NGINX | http://localhost:30080 | - |
| Grafana | http://localhost:30300 | admin/enterprise123 |
| Prometheus | http://localhost:30090 | - |
| ArgoCD | http://localhost:30200 | admin/Nightagent2025@ |
| AlertManager | http://localhost:30094 | - |

### Staging Environment
- **Cluster Name**: `ktayl-staging`
- **Git Branch**: `staging`
- **Port Range**: `31xxx`

| Service | URL | Credentials |
|---------|-----|-------------|
| NGINX | http://localhost:31080 | - |
| Grafana | http://localhost:31300 | admin/enterprise123 |
| Prometheus | http://localhost:31090 | - |
| ArgoCD | http://localhost:31200 | admin/Nightagent2025@ |
| AlertManager | http://localhost:31094 | - |

### Production Environment
- **Cluster Name**: `ktayl-prod`
- **Git Branch**: `main`
- **Port Range**: `32xxx`

| Service | URL | Credentials |
|---------|-----|-------------|
| NGINX | http://localhost:32080 | - |
| Grafana | http://localhost:32300 | admin/enterprise123 |
| Prometheus | http://localhost:32090 | - |
| ArgoCD | http://localhost:32200 | admin/Nightagent2025@ |
| AlertManager | http://localhost:32094 | - |

## ⚙️ Manual Deployment (Alternative)

If you prefer manual deployment or need to customize:

```bash
# Navigate to environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply deployment
terraform apply

# View outputs
terraform output
```

## 🔧 Configuration

### Git Repository Configuration
Update `terraform/environments/{env}/terraform.tfvars`:

```hcl
argocd_admin_password = "Nightagent2025@"
git_repo_url = "https://github.com/YourUsername/YourRepo"
git_username = "YourUsername"
git_password = "your_github_pat_token_here"
```

### Custom Ports
Modify the `ports` section in each environment's `main.tf`:

```hcl
ports = {
  http = "30080"              # NGINX HTTP
  https = "30443"             # NGINX HTTPS
  grafana = "30300"           # Grafana Dashboard
  prometheus = "30090"        # Prometheus Server
  argocd = "30200"           # ArgoCD UI
  alertmanager = "30094"     # AlertManager
}
```

## 🧹 Cleanup

### Clean Single Environment
```bash
./scripts/cleanup.sh dev
```

### Clean All Environments
```bash
./scripts/cleanup.sh
```

## ✅ Verification

After deployment, verify each environment:

1. **Check cluster status**:
```bash
k3d cluster list
kubectl get nodes --context=k3d-ktayl-dev
```

2. **Access web interfaces**:
   - Visit each service URL from the tables above
   - Login with provided credentials
   - Verify dashboards load properly

3. **Test GitOps workflow**:
   - Push changes to respective Git branches
   - Watch ArgoCD sync applications
   - Monitor in Grafana dashboards

## 🔍 Troubleshooting

### Common Issues

**Port conflicts**:
```bash
# Check if ports are in use
lsof -i :30080
```

**Cluster not starting**:
```bash
# Restart cluster
k3d cluster stop ktayl-dev
k3d cluster start ktayl-dev
```

**ArgoCD not syncing**:
```bash
# Check ArgoCD logs
kubectl logs -n argocd deployment/argo-cd-server --context=k3d-ktayl-dev
```

See [troubleshooting.md](troubleshooting.md) for detailed solutions.

## 🎯 Next Steps

1. **Test Infrastructure**: Verify all services are accessible
2. **Configure Git Branches**: Set up dev, staging, main branches
3. **Deploy Applications**: Use ArgoCD to deploy your applications
4. **Monitor & Alert**: Configure Grafana dashboards and alerts
5. **Scale**: Add more environments or applications as needed

## 📚 Additional Resources

- [Operations Guide](operations.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Terraform Modules Documentation](../terraform/modules/)