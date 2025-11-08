# 🚀 K8s Cluster Template - Complete Guide

## 📋 Overview

This repository is a **production-ready template** for creating enterprise-grade Kubernetes clusters with:
- ✅ **Multi-environment setup** (dev/staging/prod)
- ✅ **GitOps with ArgoCD**
- ✅ **Full observability stack** (Prometheus, Grafana, Alertmanager)
- ✅ **Ingress controller** (Nginx)
- ✅ **Secret management** (Sealed Secrets)
- ✅ **Infrastructure as Code** (Terraform)
- ✅ **Local development** (k3d)

---

## 🎯 Template Options for New Projects

### **Option 1: GitHub Template Repository** ⭐ RECOMMENDED

#### Setup as Template
1. Push this repository to GitHub
2. Go to Settings → Check "Template repository"
3. For new projects, click "Use this template"

#### Using the Template
```bash
# Clone from template
gh repo create my-new-project --template YOUR_USERNAME/k8s-cluster-template --private
cd my-new-project

# Initialize for your project
./scripts/init-template.sh

# Deploy
./scripts/create-cluster.sh dev
```

**Pros:**
- Clean history for each project
- Easy updates from template
- GitHub integration
- Keeps template improvements separate

---

### **Option 2: Terraform Module Registry**

Convert this into a Terraform module published to GitHub or Terraform Registry.

#### Structure
```
my-k8s-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── k3d-cluster/
    ├── argocd/
    ├── monitoring/
    ├── ingress/
    └── sealed-secrets/
```

#### Usage
```hcl
module "dev_cluster" {
  source = "github.com/YOUR_ORG/k8s-cluster-module"
  
  environment     = "dev"
  cluster_name    = "myapp-dev"
  git_repo_url    = "https://github.com/myorg/myapp"
  git_username    = var.git_username
  git_password    = var.git_password
  
  # Port mappings
  http_port       = "30080"
  https_port      = "30443"
  argocd_port     = "30200"
  grafana_port    = "30300"
  prometheus_port = "30090"
}
```

**Pros:**
- Versioned releases
- Easy to share across teams
- Can be published publicly
- Centralized updates

---

### **Option 3: Cookiecutter Template**

Create a Cookiecutter template for Python-based scaffolding.

#### Install Cookiecutter
```bash
pip install cookiecutter
```

#### Create Template Structure
```
cookiecutter-k8s-cluster/
├── cookiecutter.json
└── {{cookiecutter.project_name}}/
    ├── terraform/
    └── scripts/
```

#### `cookiecutter.json`
```json
{
  "project_name": "my-project",
  "cluster_name": "{{ cookiecutter.project_name }}",
  "git_repo_url": "https://github.com/myorg/{{ cookiecutter.project_name }}",
  "argocd_password": "change-me",
  "grafana_password": "enterprise123"
}
```

#### Usage
```bash
cookiecutter gh:YOUR_ORG/cookiecutter-k8s-cluster
```

**Pros:**
- Interactive prompts
- Variable substitution
- Python ecosystem
- Can generate any file type

---

### **Option 4: Helm Chart Wrapper**

Package everything as a Helm "umbrella chart" with sub-charts.

#### Structure
```
k8s-cluster-chart/
├── Chart.yaml
├── values.yaml
└── charts/
    ├── argocd/
    ├── prometheus/
    ├── ingress-nginx/
    └── sealed-secrets/
```

#### `values.yaml`
```yaml
global:
  clusterName: myapp-dev
  gitRepo: https://github.com/myorg/myapp

argocd:
  enabled: true
  adminPassword: change-me

monitoring:
  enabled: true
  prometheus:
    port: 30090
  grafana:
    port: 30300
```

#### Usage
```bash
helm install my-cluster ./k8s-cluster-chart \
  --set global.clusterName=myapp-dev \
  --set global.gitRepo=https://github.com/myorg/myapp
```

**Pros:**
- Standard Kubernetes tooling
- Easy to customize
- Values-driven configuration
- Helm ecosystem

---

### **Option 5: GitOps Repository Template**

Create a minimal template focusing on GitOps structure.

#### Structure
```
gitops-template/
├── infrastructure/
│   └── terraform/           # This current repo
├── applications/
│   ├── base/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
└── scripts/
    └── bootstrap.sh
```

#### Usage
```bash
# Clone template
git clone template-repo my-new-app
cd my-new-app

# Bootstrap infrastructure
cd infrastructure/terraform/environments/dev
terraform init && terraform apply

# Deploy apps via ArgoCD
kubectl apply -f applications/overlays/dev/
```

**Pros:**
- Complete GitOps workflow
- Application + infrastructure
- Follows best practices
- Scalable structure

---

### **Option 6: Docker-based CLI Tool**

Create a containerized CLI tool for cluster management.

```bash
# Build once
docker build -t k8s-cluster-template .

# Use anywhere
docker run -it k8s-cluster-template create \
  --name myapp-dev \
  --git-repo https://github.com/myorg/myapp \
  --environment dev
```

**Pros:**
- No local dependencies
- Consistent environment
- Easy distribution
- Cross-platform

---

### **Option 7: Terragrunt with Remote Modules**

Use Terragrunt for DRY Terraform configurations.

#### Structure
```
terragrunt/
├── terragrunt.hcl
└── environments/
    ├── dev/
    │   └── terragrunt.hcl
    ├── staging/
    │   └── terragrunt.hcl
    └── prod/
        └── terragrunt.hcl
```

#### `terragrunt.hcl`
```hcl
terraform {
  source = "github.com/YOUR_ORG/k8s-modules//cluster"
}

inputs = {
  cluster_name = "myapp-${path_relative_to_include()}"
  environment  = path_relative_to_include()
}
```

**Pros:**
- DRY configurations
- Remote state management
- Dependency management
- Advanced Terraform features

---

## 🔧 Customization Guide

### Quick Customizations

#### 1. Change Cluster Name
```bash
# Find and replace in all environment files
find terraform/environments -name "main.tf" -exec sed -i 's/ktayl/YOUR_PROJECT/g' {} \;
```

#### 2. Change Ports
Edit `terraform/environments/{env}/main.tf`:
```hcl
ports = {
  http = "40080"  # Change all ports as needed
  https = "40443"
  # ... etc
}
```

#### 3. Add Custom Module
```bash
# Create new module
mkdir terraform/modules/my-app

# Add to environment
# Edit terraform/environments/dev/main.tf
module "my_app" {
  source = "../../modules/my-app"
  cluster_context = module.k3d_cluster.context_name
}
```

#### 4. Remove Components
Comment out unwanted modules in `main.tf`:
```hcl
# module "sealed_secrets" {
#   ...
# }
```

---

## 📦 Pre-configured Templates

### Template 1: Minimal (Just Cluster + ArgoCD)
- k3d cluster
- ArgoCD
- Basic ingress

### Template 2: Standard (Current)
- Everything included
- Full observability
- Production-ready

### Template 3: Advanced
- Multi-region support
- Service mesh (Istio)
- Advanced monitoring
- Backup solutions

---

## 🚀 Quick Start Workflows

### For Your Next Project
```bash
# 1. Clone template
git clone https://github.com/YOUR_USERNAME/k8s-cluster-template my-new-project
cd my-new-project

# 2. Run initialization
./scripts/init-template.sh

# 3. Deploy
./scripts/create-cluster.sh dev

# 4. Start coding!
```

### For Team Projects
```bash
# 1. Use as GitHub template
gh repo create team-project --template YOUR_ORG/k8s-cluster-template

# 2. Clone for team
git clone git@github.com:YOUR_ORG/team-project.git

# 3. Each developer deploys locally
cd team-project
./scripts/create-cluster.sh dev
```

---

## 📚 Additional Resources

- **Terraform Registry**: Publish reusable modules
- **Helm Hub**: Share charts with community  
- **GitHub Actions**: Automate template updates
- **Terraform Cloud**: Remote state and collaboration

---

## 🎓 Best Practices

1. **Keep Secrets Out of Repo**: Use `.tfvars.example` files
2. **Version Your Modules**: Tag releases for stability
3. **Document Changes**: Update CHANGELOG.md
4. **Test Before Releasing**: Validate on fresh clone
5. **Maintain Examples**: Keep working examples updated

---

## 🤝 Contributing to Template

```bash
# Create feature branch
git checkout -b feature/add-new-module

# Make changes
# Test thoroughly

# Submit PR to template repo
gh pr create --title "Add new module" --body "Description"
```

---

## ⚡ Performance Tips

- **Resource Limits**: Set appropriate limits per environment
- **Node Sizing**: Adjust agent count based on workload
- **Monitoring**: Use resource quotas
- **Cleanup**: Stop unused clusters with `k3d cluster stop`

---

**Choose the option that best fits your workflow! Option 1 (GitHub Template) + init script is recommended for most use cases.** 🎉
