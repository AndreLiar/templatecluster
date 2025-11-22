# 🚀 Multi-Cluster Kubernetes Infrastructure Template

> **Production-ready, multi-environment Kubernetes setup with GitOps automation**

[View on GitHub](https://github.com/AndreLiar/templatecluster) | [Quick Start](#quick-start) | [Documentation](#documentation)

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

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/AndreLiar/templatecluster.git
cd templatecluster

# 2. Deploy dev environment
./scripts/create-cluster.sh dev

# 3. Access your services
# ArgoCD:  http://localhost:30200
# Grafana: http://localhost:30300
```

**Get credentials:**
```bash
cat terraform/environments/dev/.credentials
```

---

## 📚 Documentation

### Getting Started
- [README](https://github.com/AndreLiar/templatecluster#readme) - Complete setup guide
- [FAQ](FAQ.md) - 40+ frequently asked questions
- [Setup Guide](setup.md) - Detailed installation instructions
- [Windows Guide](WINDOWS_GUIDE.md) - Windows-specific instructions

### Advanced Topics
- [Enterprise Use Cases](ENTERPRISE_USE_CASES.md) - Real-world scenarios and applications
- [Enterprise Roles](ENTERPRISE_ROLES.md) - Team structure and responsibilities
- [Helm vs YAML](HELM_VS_YAML.md) - Package management explained
- [Template Usage](TEMPLATE_USAGE.md) - How to use this template

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

---

## 📦 Components

| Component | Description | Version |
|-----------|-------------|---------|
| **k3d** | Lightweight Kubernetes in Docker | 5.8+ |
| **ArgoCD** | GitOps continuous delivery | Latest |
| **Prometheus** | Metrics and monitoring | Latest |
| **Grafana** | Visualization and dashboards | Latest |
| **NGINX Ingress** | Traffic management | Latest |
| **Cert-Manager** | TLS certificate automation | Latest |
| **Sealed Secrets** | Secret encryption | Latest |

---

## 🎯 Who Is This For?

- **Developers** learning Kubernetes
- **DevOps teams** building internal platforms
- **Companies** evaluating Kubernetes
- **Training** and education
- **POCs** and demos
- **Migration** planning

---

## 💡 Use Cases

### Local Development
Perfect for developing and testing Kubernetes applications locally without cloud costs.

### CI/CD Testing
Integrate into your CI/CD pipeline to test deployments before production.

### Training & Education
Hands-on learning environment for Kubernetes, GitOps, and infrastructure as code.

### Migration Planning
Test migration strategies and validate configurations before moving to cloud.

[Read more use cases →](ENTERPRISE_USE_CASES.md)

---

## 🛠️ Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Docker Desktop | Latest | [Download](https://www.docker.com/products/docker-desktop) |
| kubectl | 1.28+ | [Install](https://kubernetes.io/docs/tasks/tools/) |
| k3d | 5.8+ | [Install](https://k3d.io/) |
| Terraform | 1.5+ | [Install](https://www.terraform.io/) |

**System Requirements:**
- RAM: 8GB minimum (16GB recommended)
- Disk: 10GB free space
- CPU: 4+ cores recommended

---

## 📖 Deployment Profiles

| Profile | Components | Use Case |
|---------|------------|----------|
| **Minimal** | k3d + ArgoCD + Ingress | Quick demos, learning |
| **Standard** | + Monitoring + Secrets | Development, testing |
| **Full** | + Network Policies | Production simulation |

---

## 🔄 GitOps Workflow

1. **Deploy infrastructure** with Terraform
2. **ArgoCD watches** your Git repository
3. **Push changes** to Git
4. **Auto-deployment** to Kubernetes

[Learn more about GitOps →](https://www.gitops.tech/)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

[View on GitHub](https://github.com/AndreLiar/templatecluster)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/AndreLiar/templatecluster/blob/main/LICENSE) file for details.

---

## 🙏 Acknowledgments

Built with:
- [k3d](https://k3d.io/) - Lightweight Kubernetes in Docker
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [ArgoCD](https://argoproj.github.io/cd/) - GitOps continuous delivery
- [Prometheus](https://prometheus.io/) - Monitoring and alerting
- [Grafana](https://grafana.com/) - Analytics and monitoring

---

**Made with ❤️ for the Kubernetes community**

[⬆ Back to top](#-multi-cluster-kubernetes-infrastructure-template)
