# Using This as a Template for New Projects

## Quick Start

### 1. Clone This Template
```bash
git clone https://github.com/YOUR_USERNAME/k8s-cluster-template my-new-project
cd my-new-project
```

### 2. Customize for Your Project
```bash
# Update variables in each environment
vim terraform/environments/dev/terraform.tfvars
vim terraform/environments/staging/terraform.tfvars
vim terraform/environments/prod/terraform.tfvars
```

### 3. Deploy
```bash
# Single environment
cd terraform/environments/dev
terraform init
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve

# Or use script
./scripts/create-cluster.sh dev
```

## What You Get Out of the Box

✅ **3 Pre-configured Environments** (dev/staging/prod)
✅ **GitOps Ready** - ArgoCD installed and configured
✅ **Full Observability** - Prometheus + Grafana + Alertmanager
✅ **Ingress Ready** - Nginx Ingress Controller
✅ **Secret Management** - Sealed Secrets
✅ **Multi-cluster Support** - Isolated environments
✅ **Port-mapped Services** - Easy localhost access

## Customization Points

### 1. Cluster Name
File: `terraform/environments/{env}/main.tf`
```hcl
locals {
  cluster_name = "YOUR-PROJECT-${local.environment}"  # Change here
}
```

### 2. Git Repository
File: `terraform/environments/{env}/terraform.tfvars`
```hcl
git_repo_url = "https://github.com/YOUR_ORG/YOUR_REPO"
git_username = "your-username"
git_password = "your-token"
```

### 3. Ports
File: `terraform/environments/{env}/main.tf`
```hcl
ports = {
  http = "30080"        # Change as needed
  https = "30443"
  grafana = "30300"
  prometheus = "30090"
  argocd = "30200"
  alertmanager = "30094"
}
```

### 4. Credentials
File: `terraform/environments/{env}/terraform.tfvars`
```hcl
argocd_admin_password = "YOUR_SECURE_PASSWORD"
```

## Module Customization

### Add/Remove Modules
Edit: `terraform/environments/{env}/main.tf`

```hcl
# Remove a module (e.g., sealed-secrets)
# Just comment out or delete:
# module "sealed_secrets" {
#   source = "../../modules/sealed-secrets"
#   cluster_context = module.k3d_cluster.context_name
# }

# Add a new module
module "custom_app" {
  source = "../../modules/custom-app"
  cluster_context = module.k3d_cluster.context_name
}
```

## Creating New Modules

```bash
mkdir -p terraform/modules/my-new-module
```

Create `terraform/modules/my-new-module/main.tf`:
```hcl
variable "cluster_context" {
  description = "Kubernetes cluster context"
  type        = string
}

resource "helm_release" "my_app" {
  name       = "my-app"
  repository = "https://charts.example.com"
  chart      = "my-app"
  namespace  = "my-namespace"
  
  # Your configuration here
}
```

## Resource Considerations

**Single Environment:**
- CPU: ~300%
- Memory: ~3GB
- Pods: ~18

**Multiple Environments:**
- Ensure sufficient resources
- Consider running one environment at a time
- Use `k3d cluster stop <name>` to pause unused clusters

## Best Practices

1. **Version Control**: Commit `.tfvars.example` but not `.tfvars` with secrets
2. **Secrets**: Use environment variables or secret managers for sensitive data
3. **State Management**: Use remote backend (S3, Terraform Cloud) for team projects
4. **Resource Limits**: Set appropriate limits for production workloads
5. **Monitoring**: Configure Grafana dashboards for your specific apps

## Troubleshooting

### Provider Context Error
If you get "context does not exist" error:
```bash
# Apply in two stages
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve
```

### Resource Issues
```bash
# Check cluster resources
k3d cluster list
docker stats

# Stop unused clusters
k3d cluster stop <cluster-name>
```

### Clean Up
```bash
# Destroy specific environment
cd terraform/environments/dev
terraform destroy -auto-approve

# Or use k3d directly
k3d cluster delete <cluster-name>
```
