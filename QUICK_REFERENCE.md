# 🎯 Quick Reference Card

## 🚀 One-Command Deployment

### New Project from Template
```bash
# Clone
git clone https://github.com/YOUR_USERNAME/k8s-cluster-template my-new-project
cd my-new-project

# Initialize (interactive)
./scripts/init-template.sh

# Deploy
./scripts/create-cluster.sh dev
```

### Quick Deploy (One-liner)
```bash
./scripts/quick-deploy.sh myproject https://github.com/myorg/repo dev
```

---

## 📊 Template Options Comparison

| Option | Best For | Complexity | Team Size |
|--------|----------|------------|-----------|
| **GitHub Template** ⭐ | Most projects | Low | Any |
| **Terraform Module** | Reusable infra | Medium | Medium-Large |
| **Cookiecutter** | Python shops | Low | Small-Medium |
| **Helm Chart** | K8s-native teams | Medium | Medium |
| **GitOps Repo** | Full workflows | High | Large |
| **Docker CLI** | Simplicity | Low | Small |
| **Terragrunt** | Complex setups | High | Large |

---

## 🎨 Customization Cheat Sheet

### Change Cluster Name
```bash
# In terraform/environments/{env}/main.tf
cluster_name = "YOUR_PROJECT-${local.environment}"
```

### Change Ports
```bash
# In terraform/environments/{env}/main.tf
ports = {
  http = "40080"  # Your custom ports
  https = "40443"
  argocd = "40200"
}
```

### Add New Module
```bash
mkdir terraform/modules/my-app
# Create main.tf in new module
# Add to environments/{env}/main.tf:
module "my_app" {
  source = "../../modules/my-app"
  cluster_context = module.k3d_cluster.context_name
}
```

### Remove Component
```bash
# Comment out in environments/{env}/main.tf
# module "sealed_secrets" { ... }
```

---

## 🔧 Common Commands

### Cluster Management
```bash
# List clusters
k3d cluster list

# Stop cluster
k3d cluster stop ktayl-dev

# Start cluster
k3d cluster start ktayl-dev

# Delete cluster
k3d cluster delete ktayl-dev
```

### Terraform
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply (two-stage for new clusters)
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve

# Destroy
terraform destroy
```

### Kubernetes
```bash
# Switch context
kubectl config use-context k3d-ktayl-dev

# Check pods
kubectl get pods -A

# Check services
kubectl get svc -A

# Port forward ArgoCD
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
```

---

## 📍 Access URLs

### Dev Environment (30xxx)
- ArgoCD: http://localhost:30200
- Grafana: http://localhost:30300
- Prometheus: http://localhost:30090
- Alertmanager: http://localhost:30094

### Staging Environment (31xxx)
- ArgoCD: http://localhost:31200
- Grafana: http://localhost:31300
- Prometheus: http://localhost:31090

### Prod Environment (32xxx)
- ArgoCD: http://localhost:32200
- Grafana: http://localhost:32300
- Prometheus: http://localhost:32090

---

## 🔐 Default Credentials

**ArgoCD:**
- Username: `admin`
- Password: `Nightagent2025@` (change in tfvars)

**Grafana:**
- Username: `admin`
- Password: `enterprise123`

---

## 📁 Project Structure

```
infraAks/
├── scripts/
│   ├── init-template.sh      # Initialize new project
│   ├── quick-deploy.sh        # One-command deploy
│   ├── create-cluster.sh      # Deploy single environment
│   └── deploy-all.sh          # Deploy all environments
├── terraform/
│   ├── modules/               # Reusable components
│   │   ├── k3d-cluster/
│   │   ├── argocd/
│   │   ├── monitoring/
│   │   ├── ingress/
│   │   └── sealed-secrets/
│   └── environments/          # Environment configs
│       ├── dev/
│       ├── staging/
│       └── prod/
├── docs/
│   ├── TEMPLATE_USAGE.md      # Detailed usage guide
│   └── setup.md
├── TEMPLATE_GUIDE.md          # All template options
└── QUICK_REFERENCE.md         # This file
```

---

## ⚡ Resource Requirements

### Single Environment
- **CPU**: ~300%
- **Memory**: ~3GB
- **Pods**: ~18
- **Storage**: ~2GB

### Multiple Environments
- **2 Clusters**: ~600% CPU, ~6GB RAM
- **3 Clusters**: ~900% CPU, ~9GB RAM (may require optimization)

---

## 🐛 Troubleshooting

### "Context does not exist" Error
```bash
# Apply in two stages
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve
```

### Resource Exhaustion
```bash
# Stop unused clusters
k3d cluster stop ktayl-staging ktayl-prod

# Check resources
docker stats

# Delete if needed
k3d cluster delete ktayl-staging
```

### Pods Not Starting
```bash
# Check pod status
kubectl get pods -A --context=k3d-ktayl-dev

# Describe pod
kubectl describe pod POD_NAME -n NAMESPACE

# Check logs
kubectl logs POD_NAME -n NAMESPACE
```

### Port Already in Use
```bash
# Find process using port
lsof -i :30200

# Change ports in main.tf or kill process
```

---

## 🎓 Learning Resources

- **Terraform**: https://learn.hashicorp.com/terraform
- **k3d**: https://k3d.io/
- **ArgoCD**: https://argo-cd.readthedocs.io/
- **Prometheus**: https://prometheus.io/docs/
- **Helm**: https://helm.sh/docs/

---

## 📞 Getting Help

1. Check `TEMPLATE_GUIDE.md` for detailed options
2. Review `docs/TEMPLATE_USAGE.md` for usage examples
3. Check logs: `kubectl logs -n argocd POD_NAME`
4. Verify resources: `docker stats`

---

## ✅ Checklist for New Projects

- [ ] Clone template repository
- [ ] Run `./scripts/init-template.sh`
- [ ] Update Git repository URLs
- [ ] Update passwords in terraform.tfvars
- [ ] Test dev deployment
- [ ] Customize modules as needed
- [ ] Update README with project-specific info
- [ ] Set up remote state backend (optional)
- [ ] Configure CI/CD (optional)

---

**Ready to deploy? Start with:** `./scripts/init-template.sh` 🚀
