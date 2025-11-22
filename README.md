# 🚀 Multi-Cluster Kubernetes Infrastructure Template

> **Production-ready, multi-environment Kubernetes setup with GitOps automation**

Deploy complete Kubernetes infrastructure in minutes with ArgoCD, Prometheus, Grafana, and more - all automated with Terraform and k3d.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![k3d](https://img.shields.io/badge/k3d-5.8+-blue.svg)](https://k3d.io/)

---

## ✨ Features

- 🎯 **Multi-Cluster Architecture** - Separate clusters for dev, staging, and production
- 🔄 **GitOps Ready** - ArgoCD for automated deployments
- 📊 **Full Observability** - Prometheus + Grafana monitoring stack
- 🔒 **Security Built-in** - Cert-Manager, Sealed Secrets, Network Policies
- 🎚️ **Flexible Profiles** - Minimal, Standard, or Full deployment options
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux
- 📦 **Infrastructure as Code** - Everything defined in Terraform
- ⚡ **One-Command Deploy** - Get running in under 5 minutes

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Multi-Cluster Infrastructure                   │
├──────────────────┬──────────────────┬───────────────────────┤
│   DEV CLUSTER    │ STAGING CLUSTER  │   PROD CLUSTER        │
│   HDI-dev        │   HDI-stage      │   HDI-prod            │
│   Port: 30xxx    │   Port: 31xxx    │   Port: 32xxx         │
├──────────────────┼──────────────────┼───────────────────────┤
│ • ArgoCD         │ • ArgoCD         │ • ArgoCD              │
│ • Prometheus     │ • Prometheus     │ • Prometheus          │
│ • Grafana        │ • Grafana        │ • Grafana             │
│ • NGINX Ingress  │ • NGINX Ingress  │ • NGINX Ingress       │
│ • Cert-Manager   │ • Cert-Manager   │ • Cert-Manager        │
│ • Sealed Secrets │ • Sealed Secrets │ • Sealed Secrets      │
└──────────────────┴──────────────────┴───────────────────────┘
```

**Each cluster includes:**
- 1 Control Plane (server)
- 2 Worker Nodes (agents)
- Load Balancer
- Complete isolation from other environments

---

## 🚀 Quick Start

### Prerequisites

Install these tools first:

| Tool | Version | Windows | macOS | Linux |
|------|---------|---------|-------|-------|
| [Docker Desktop](https://www.docker.com/products/docker-desktop) | Latest | [Download](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe) | [Download](https://desktop.docker.com/mac/main/amd64/Docker.dmg) | [Install Guide](https://docs.docker.com/engine/install/) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.28+ | `choco install kubernetes-cli` | `brew install kubectl` | [Install Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) |
| [k3d](https://k3d.io/) | 5.8+ | `choco install k3d` | `brew install k3d` | `wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh \| bash` |
| [Terraform](https://www.terraform.io/) | 1.5+ | `choco install terraform` | `brew install terraform` | [Install Guide](https://developer.hashicorp.com/terraform/install) |

**System Requirements:**
- RAM: 8GB minimum (16GB recommended for all 3 clusters)
- Disk: 10GB free space
- CPU: 4+ cores recommended

**Windows Users:** Install [Chocolatey](https://chocolatey.org/install) first for easy package management.

### Verify Installation

```bash
docker --version && kubectl version --client && k3d version && terraform version
```

### Deploy in 3 Steps

```bash
# 1. Clone the repository
git clone https://github.com/AndreLiar/templatecluster.git
cd templatecluster

# 2. Deploy dev environment (Standard profile - recommended)
./scripts/create-cluster.sh dev

# OR choose a different profile:
# ./scripts/create-cluster.sh dev minimal  # Lightweight (2-4GB RAM)
# ./scripts/create-cluster.sh dev full     # Production-like (6-12GB RAM)

# 3. Access your services
# ArgoCD:  http://localhost:30200
# Grafana: http://localhost:30300
```

**Get credentials:**
```bash
cat terraform/environments/dev/.credentials
```

**That's it!** You now have a fully functional Kubernetes cluster with monitoring and GitOps. 🎉

**💡 Not sure which profile to use?** See [Which Profile Should I Use?](#-which-profile-should-i-use) below.

---

## 🎯 Which Profile Should I Use?

Choose based on your needs and available resources:

### 🚀 **Minimal Profile** - Quick Start & Learning

**Perfect for:**
- ✅ Learning Kubernetes basics
- ✅ Quick demos and presentations
- ✅ Limited resources (4GB RAM laptop)
- ✅ Just need GitOps (ArgoCD) + Ingress

**Deploy:**
```bash
./scripts/create-cluster.sh dev minimal
```

**What you get:**
- k3d Kubernetes cluster
- ArgoCD (GitOps automation)
- NGINX Ingress (traffic management)

**Resources:** ~2-4GB RAM, 2 CPUs, 5GB disk  
**Deploy time:** ~3 minutes

---

### 💼 **Standard Profile** - Development & Testing ⭐ **RECOMMENDED**

**Perfect for:**
- ✅ Local application development
- ✅ Testing and integration
- ✅ Need monitoring and observability
- ✅ Most common use case

**Deploy:**
```bash
./scripts/create-cluster.sh dev
# OR explicitly:
./scripts/create-cluster.sh dev standard
```

**What you get:**
- Everything in Minimal, PLUS:
- Prometheus (metrics collection)
- Grafana (dashboards and visualization)
- Cert-Manager (TLS certificate automation)
- Sealed Secrets (secret encryption)

**Resources:** ~4-8GB RAM, 4 CPUs, 10GB disk  
**Deploy time:** ~5 minutes

---

### 🏢 **Full Profile** - Production Simulation

**Perfect for:**
- ✅ Testing production configurations
- ✅ Security validation and compliance
- ✅ Network policy testing
- ✅ Enterprise evaluation

**Deploy:**
```bash
./scripts/create-cluster.sh dev full
```

**What you get:**
- Everything in Standard, PLUS:
- Network Policies (network security)
- Production-like security hardening

**Resources:** ~6-12GB RAM, 4 CPUs, 15GB disk  
**Deploy time:** ~7 minutes

---

### 📊 Quick Comparison

| Feature | Minimal | Standard ⭐ | Full |
|---------|---------|----------|------|
| **Use Case** | Learning, Demos | Development | Production Testing |
| **RAM Required** | 2-4GB | 4-8GB | 6-12GB |
| **Deploy Time** | 3 min | 5 min | 7 min |
| **k3d Cluster** | ✅ | ✅ | ✅ |
| **ArgoCD (GitOps)** | ✅ | ✅ | ✅ |
| **NGINX Ingress** | ✅ | ✅ | ✅ |
| **Prometheus** | ❌ | ✅ | ✅ |
| **Grafana** | ❌ | ✅ | ✅ |
| **Cert-Manager** | ❌ | ✅ | ✅ |
| **Sealed Secrets** | ❌ | ✅ | ✅ |
| **Network Policies** | ❌ | ❌ | ✅ |

**💡 Recommendation:** Start with **Standard** (default) - it's the best balance of features and resources.

---

## 📖 Detailed Usage

### Deploy Different Environments

```bash
# Development
./scripts/create-cluster.sh dev [minimal|standard|full]

# Staging
./scripts/create-cluster.sh staging [minimal|standard|full]

# Production
./scripts/create-cluster.sh prod [minimal|standard|full]
```

### Two Ways to Deploy

**Method 1: Using Scripts (Recommended)**
```bash
./scripts/create-cluster.sh dev [minimal|standard|full]
```
✅ Easiest way - handles everything for you  
✅ Recommended for most users

**Method 2: Using Terraform Directly (Advanced)**
```bash
cd terraform/environments/dev
terraform apply -var="deployment_profile=minimal"
```
✅ More control - for advanced users  
✅ Useful for customization

**💡 Recommendation:** Use Method 1 (scripts) unless you need to customize Terraform configurations.

### Test Cluster Health

**PowerShell (Windows):**
```powershell
.\scripts\test-cluster.ps1 dev
```

**Bash (Linux/Mac):**
```bash
./scripts/test-cluster.sh dev
```

### Access Services

**Development Environment:**
| Service | URL | Default Credentials |
|---------|-----|---------------------|
| ArgoCD | http://localhost:30200 | admin / (see .credentials) |
| Grafana | http://localhost:30300 | admin / (see .credentials) |
| Prometheus | http://localhost:30090 | - |
| Alertmanager | http://localhost:30094 | - |

**Staging Environment:**
| Service | URL |
|---------|-----|
| ArgoCD | http://localhost:31200 |
| Grafana | http://localhost:31300 |
| Prometheus | http://localhost:31090 |

**Production Environment:**
| Service | URL |
|---------|-----|
| ArgoCD | http://localhost:32200 |
| Grafana | http://localhost:32300 |
| Prometheus | http://localhost:32090 |

---

## 🔄 GitOps Workflow

### Enable GitOps Automation

1. **Deploy bootstrap application:**
```bash
kubectl apply -f kubernetes/argocd/bootstrap-app.yaml --context k3d-HDI-dev
```

2. **Add your applications:**
Create application manifests in `kubernetes/applications/`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/your-repo.git
    targetRevision: HEAD
    path: kubernetes/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

3. **Push to Git** - ArgoCD automatically syncs!

---

## 📁 Project Structure

```
templatecluster/
├── README.md                          # This file
├── terraform/                         # Infrastructure as Code
│   ├── modules/                       # Reusable modules
│   │   ├── k3d-cluster/              # Cluster creation
│   │   ├── argocd/                   # GitOps platform
│   │   ├── monitoring/               # Prometheus + Grafana
│   │   ├── ingress/                  # NGINX Ingress
│   │   ├── cert-manager/             # TLS certificates
│   │   ├── sealed-secrets/           # Secret encryption
│   │   └── network-policies/         # Network security
│   └── environments/                  # Environment configs
│       ├── dev/                       # Development
│       ├── staging/                   # Staging
│       └── prod/                      # Production
├── kubernetes/                        # Kubernetes manifests
│   ├── argocd/                       # ArgoCD bootstrap
│   ├── applications/                 # ArgoCD applications
│   └── base/                         # Base manifests
├── scripts/                          # Automation scripts
│   ├── create-cluster.sh             # Deploy cluster
│   ├── test-cluster.sh               # Test cluster (bash)
│   └── test-cluster.ps1              # Test cluster (PowerShell)
└── .github/                          # CI/CD workflows
    └── workflows/
        └── terraform-ci.yml          # Terraform validation
```

---

## 🛠️ Common Tasks

### View Cluster Status

```bash
# List all clusters
k3d cluster list

# Get all pods
kubectl get pods -A --context k3d-HDI-dev

# Get all services
kubectl get svc -A --context k3d-HDI-dev
```

### Stop/Start Clusters

```bash
# Stop cluster
k3d cluster stop HDI-dev

# Start cluster
k3d cluster start HDI-dev
```

### Delete Cluster

```bash
# Delete specific cluster
k3d cluster delete HDI-dev

# Or use cleanup script
./scripts/cleanup.sh dev
```

### Update Configuration

```bash
cd terraform/environments/dev
terraform plan
terraform apply
```

---

## 🔧 Customization

### Change Cluster Configuration

Edit `terraform/modules/k3d-cluster/main.tf`:

```hcl
# Change number of agents (worker nodes)
agents = 3  # Default: 2

# Change Kubernetes version
image = "rancher/k3s:v1.31.5-k3s1"
```

### Configure Git Repository

Edit `terraform/environments/dev/variables.tf`:

```hcl
variable "git_repo_url" {
  default = "https://github.com/your-username/your-repo.git"
}

variable "git_username" {
  default = "your-username"
}

variable "git_password" {
  default = ""  # Use Personal Access Token
  sensitive = true
}
```

### Add Custom Monitoring Dashboards

Place Grafana dashboards in `terraform/modules/monitoring/dashboards/`.

---

## 🐛 Troubleshooting

### Docker Issues

**Problem:** `Cannot connect to Docker daemon`
```bash
# Solution: Start Docker Desktop
# Windows: Open Docker Desktop
# Mac: Open Docker Desktop
# Linux: sudo systemctl start docker
```

### Cluster Creation Fails

**Problem:** `cluster already exists`
```bash
# Solution: Delete existing cluster
k3d cluster delete HDI-dev
./scripts/create-cluster.sh dev
```

### Pods Not Starting

**Problem:** Pods stuck in `Pending` or `CrashLoopBackOff`
```bash
# Check pod logs
kubectl logs <pod-name> -n <namespace> --context k3d-HDI-dev

# Check pod events
kubectl describe pod <pod-name> -n <namespace> --context k3d-HDI-dev

# Check resource usage
kubectl top nodes --context k3d-HDI-dev
```

### Port Already in Use

**Problem:** `port 30200 already allocated`
```bash
# Solution: Change port in terraform/environments/dev/main.tf
locals {
  ports = {
    argocd = "30201"  # Change from 30200
  }
}
```

### Terraform State Issues

**Problem:** `state lock` or `state mismatch`
```bash
# Solution: Remove state and redeploy
cd terraform/environments/dev
rm terraform.tfstate*
terraform init
terraform apply
```

---

## 📚 Documentation

- [FAQ](docs/FAQ.md) - 40+ frequently asked questions
- [Enterprise Use Cases](docs/ENTERPRISE_USE_CASES.md) - Real-world scenarios
- [Enterprise Roles](docs/ENTERPRISE_ROLES.md) - Team structure and responsibilities
- [Helm vs YAML](docs/HELM_VS_YAML.md) - Package management explained
- [k3d Documentation](https://k3d.io/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [k3d](https://k3d.io/) - Lightweight Kubernetes in Docker
- [ArgoCD](https://argoproj.github.io/cd/) - GitOps continuous delivery
- [Prometheus](https://prometheus.io/) - Monitoring and alerting
- [Grafana](https://grafana.com/) - Analytics and monitoring
- [Cert-Manager](https://cert-manager.io/) - Certificate management
- [Sealed Secrets](https://sealed-secrets.netlify.app/) - Secret encryption

---

## 💬 Support

- 📧 Email: support@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/AndreLiar/templatecluster/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/AndreLiar/templatecluster/discussions)

---

**Made with ❤️ for the Kubernetes community**