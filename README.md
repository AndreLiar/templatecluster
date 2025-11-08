# 🏢 Enterprise Kubernetes Infrastructure

Clean, production-ready multi-environment Kubernetes setup with GitOps workflow.

## 🎯 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Enterprise Infrastructure                │
├─────────────────┬─────────────────┬─────────────────────────┤
│   DEV CLUSTER   │ STAGING CLUSTER │   PROD CLUSTER          │
│   Port: 30xxx   │   Port: 31xxx   │   Port: 32xxx          │
│   Branch: dev   │ Branch: staging │   Branch: main         │
├─────────────────┼─────────────────┼─────────────────────────┤
│ • NGINX Ingress │ • NGINX Ingress │ • NGINX Ingress        │
│ • Prometheus    │ • Prometheus    │ • Prometheus           │
│ • Grafana       │ • Grafana       │ • Grafana              │
│ • ArgoCD        │ • ArgoCD        │ • ArgoCD               │
│ • AlertManager  │ • AlertManager  │ • AlertManager         │
│ • Sealed Secrets│ • Sealed Secrets│ • Sealed Secrets       │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 📁 Project Structure

```
infraAks/
├── README.md                     # This file
├── CLAUDE.md                     # Claude assistant guidance
├── terraform/                    # Infrastructure as Code
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── k3d-cluster/         # k3d cluster creation
│   │   ├── argocd/              # ArgoCD deployment
│   │   ├── monitoring/          # Prometheus + Grafana
│   │   ├── ingress/             # NGINX Ingress
│   │   └── sealed-secrets/      # Sealed Secrets
│   └── environments/            # Environment-specific configs
│       ├── dev/                 # Development environment
│       ├── staging/             # Staging environment
│       └── prod/                # Production environment
├── scripts/                     # Automation scripts
│   ├── create-cluster.sh        # Create single environment
│   ├── deploy-all.sh            # Deploy all environments
│   └── cleanup.sh               # Clean up resources
└── docs/                        # Documentation
    └── setup.md                 # Complete setup guide
```

## 🚀 Quick Start

### Prerequisites
```bash
brew install k3d kubectl terraform helm jq
```

### Deploy Single Environment
```bash
# Deploy development environment
./scripts/create-cluster.sh dev

# Deploy staging environment  
./scripts/create-cluster.sh staging

# Deploy production environment
./scripts/create-cluster.sh prod
```

### Deploy All Environments
```bash
./scripts/deploy-all.sh
```

## 🔗 Access Points

| Environment | NGINX | Grafana | Prometheus | ArgoCD | Git Branch |
|-------------|-------|---------|------------|--------|------------|
| **Dev**     | 30080 | 30300   | 30090      | 30200  | dev        |
| **Staging** | 31080 | 31300   | 31090      | 31200  | staging    |
| **Prod**    | 32080 | 32300   | 32090      | 32200  | main       |

## 🔑 Default Credentials

- **Grafana**: admin / enterprise123
- **ArgoCD**: admin / Nightagent2025@

## 🧹 Cleanup

```bash
# Clean single environment
./scripts/cleanup.sh dev

# Clean all environments
./scripts/cleanup.sh
```

## ✨ Key Features

### **🏗️ Infrastructure as Code**
- Terraform modules for reusable components
- Environment-specific configurations
- Automated deployment scripts

### **🔄 GitOps Workflow**
- ArgoCD for continuous deployment
- Git branch per environment (dev/staging/main)
- Automatic application sync from Git

### **📊 Complete Observability**
- Prometheus for metrics collection
- Grafana for visualization and dashboards
- AlertManager for alerting

### **🔐 Enterprise Security**
- Sealed Secrets for GitOps-compatible secret management
- Network isolation between environments
- RBAC ready configurations

### **🌐 Production-Ready Networking**
- NGINX Ingress Controller
- External access via NodePort
- Service mesh ready

### **🚀 Multi-Environment**
- Complete separation of dev/staging/prod
- Independent scaling and configuration
- Real-world enterprise simulation

## 📖 Documentation

- [Complete Setup Guide](docs/setup.md) - Detailed installation and configuration
- [CLAUDE.md](CLAUDE.md) - Assistant guidance for future development

## 🎯 Next Steps

1. **Configure Git Repository**: Update `terraform.tfvars` with your repository details
2. **Deploy Infrastructure**: Run `./scripts/create-cluster.sh dev`
3. **Access Services**: Use URLs from the access points table
4. **Deploy Applications**: Push to Git branches to trigger ArgoCD sync
5. **Monitor**: Use Grafana dashboards for observability

## 💡 Usage Examples

```bash
# Quick dev environment
./scripts/create-cluster.sh dev
curl http://localhost:30080
open http://localhost:30300

# Full enterprise deployment
./scripts/deploy-all.sh

# Clean everything
./scripts/cleanup.sh
```

---

**Built for Enterprise** • **GitOps Ready** • **Production Grade** • **Multi Environment**