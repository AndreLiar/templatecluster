# ❓ Frequently Asked Questions (FAQ)

## Getting Started

### Q: I'm completely new to Kubernetes. Can I use this template?
**A:** Yes! This template is designed to be beginner-friendly. Follow the Quick Start guide in the README, and you'll have a working cluster in minutes. The template handles all the complex setup for you.

### Q: What do I need to install before using this template?
**A:** You need 4 tools:
1. Docker Desktop (for running containers)
2. kubectl (Kubernetes command-line tool)
3. k3d (creates Kubernetes clusters in Docker)
4. Terraform (infrastructure automation)

See the Prerequisites section in the README for installation links.

### Q: How long does it take to deploy?
**A:** 
- First-time setup (installing tools): 15-30 minutes
- Deploying a cluster: 3-5 minutes
- Total time to get running: ~20-35 minutes

### Q: Does this work on Windows?
**A:** Yes! The template works on Windows, macOS, and Linux. Windows users should use PowerShell and can install tools via Chocolatey.

---

## Technical Questions

### Q: What's the difference between dev, staging, and prod environments?
**A:** They are completely separate Kubernetes clusters:
- **Dev**: For development and testing (ports 30xxx)
- **Staging**: For integration testing (ports 31xxx)
- **Prod**: For production simulation (ports 32xxx)

Each runs independently and won't affect the others.

### Q: Can I run all 3 environments at the same time?
**A:** Yes, but it requires:
- 16GB RAM (minimum)
- 20GB disk space
- Good CPU (4+ cores)

For most users, running one environment at a time is sufficient.

### Q: What are deployment profiles?
**A:**
- **Minimal**: Just Kubernetes + ArgoCD + Ingress (lightweight)
- **Standard**: Adds monitoring (Prometheus/Grafana) + secrets (default)
- **Full**: Everything including network policies (production-like)

Start with Standard profile.

### Q: Is this for production use?
**A:** No, this is for:
- Local development
- Testing
- Learning
- POCs/Demos

For production, deploy to cloud providers (AWS EKS, Azure AKS, Google GKE).

---

## Troubleshooting

### Q: I get "Cannot connect to Docker daemon" error
**A:** Docker Desktop isn't running. Start Docker Desktop and wait for it to fully start (whale icon should be steady, not animated).

### Q: The script fails with "cluster already exists"
**A:** Delete the existing cluster first:
```bash
k3d cluster delete HDI-dev
./scripts/create-cluster.sh dev
```

### Q: Pods are stuck in "Pending" state
**A:** This usually means:
1. Not enough resources (RAM/CPU)
2. Docker Desktop resource limits too low

**Solution**: Increase Docker Desktop resources:
- Docker Desktop → Settings → Resources
- Set RAM to 8GB+ and CPUs to 4+

### Q: I can't access http://localhost:30200
**A:** Check:
1. Is the cluster running? `k3d cluster list`
2. Are pods ready? `kubectl get pods -A --context k3d-HDI-dev`
3. Wait 2-3 minutes for all services to start

### Q: Where are my credentials?
**A:** After deployment, credentials are in:
```bash
cat terraform/environments/dev/.credentials
```

This file is auto-generated and contains admin passwords for ArgoCD and Grafana.

---

## Usage Questions

### Q: How do I deploy my own application?
**A:** Two ways:

**Option 1: Direct kubectl**
```bash
kubectl apply -f my-app.yaml --context k3d-HDI-dev
```

**Option 2: GitOps (recommended)**
1. Create ArgoCD Application manifest in `kubernetes/applications/`
2. Push to Git
3. ArgoCD automatically deploys

### Q: How do I stop the cluster without deleting it?
**A:**
```bash
# Stop
k3d cluster stop HDI-dev

# Start again later
k3d cluster start HDI-dev
```

### Q: How do I completely remove everything?
**A:**
```bash
# Delete cluster
k3d cluster delete HDI-dev

# Delete Terraform state
cd terraform/environments/dev
rm -rf .terraform terraform.tfstate*
```

### Q: Can I change the ports (30200, 30300, etc.)?
**A:** Yes, edit `terraform/environments/dev/main.tf` and change the port mappings in the k3d_cluster module.

---

## GitOps Questions

### Q: What is GitOps?
**A:** GitOps means your infrastructure and applications are defined in Git. When you push changes to Git, ArgoCD automatically deploys them to Kubernetes.

### Q: Do I need to use GitOps?
**A:** No, it's optional. You can deploy applications directly with `kubectl apply`. GitOps is recommended for teams and production workflows.

### Q: How do I connect ArgoCD to my Git repository?
**A:** Edit `terraform/environments/dev/variables.tf`:
```hcl
variable "git_repo_url" {
  default = "https://github.com/your-username/your-repo.git"
}

variable "git_password" {
  default = "your-personal-access-token"
  sensitive = true
}
```

---

## Cost & Resources

### Q: Does this cost money?
**A:** No! Everything runs locally on your machine. No cloud costs.

### Q: How much RAM/CPU does this use?
**A:**
- **One cluster**: ~4GB RAM, 2 CPUs
- **Three clusters**: ~12GB RAM, 4+ CPUs

### Q: Can I run this on a laptop?
**A:** Yes, if your laptop has:
- 8GB+ RAM
- 4+ CPU cores
- 10GB+ free disk space

Modern laptops (2020+) should handle this fine.

---

## Comparison Questions

### Q: How is this different from Minikube?
**A:**
- **k3d** (this template): Faster, lighter, multi-cluster support
- **Minikube**: Single cluster, heavier, VM-based

k3d is better for development and testing multiple environments.

### Q: How is this different from Docker Compose?
**A:**
- **Docker Compose**: Simple container orchestration
- **Kubernetes** (this template): Production-grade orchestration with monitoring, GitOps, secrets management

Use Docker Compose for simple apps, Kubernetes for complex microservices.

### Q: Can I migrate this to cloud later?
**A:** Yes! The Terraform modules and Kubernetes manifests can be adapted for:
- AWS EKS
- Azure AKS
- Google GKE

The template is designed as a stepping stone to cloud.

---

## Advanced Questions

### Q: Can I add more worker nodes?
**A:** Yes, edit `terraform/modules/k3d-cluster/main.tf`:
```hcl
agents = 3  # Change from 2 to 3
```

### Q: Can I use a different Kubernetes version?
**A:** Yes, edit `terraform/modules/k3d-cluster/main.tf`:
```hcl
image = "rancher/k3s:v1.30.0-k3s1"  # Change version
```

### Q: Can I add custom Helm charts?
**A:** Yes, create a new Terraform module in `terraform/modules/` following the pattern of existing modules (argocd, monitoring, etc.).

### Q: How do I enable network policies?
**A:**
```bash
cd terraform/environments/dev
terraform apply -var="deployment_profile=full"
```

---

## Learning Resources

### Q: Where can I learn more about Kubernetes?
**A:**
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Kubernetes Basics Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [CNCF Kubernetes Course](https://www.cncf.io/certification/ckad/)

### Q: Where can I learn more about Terraform?
**A:**
- [Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Q: Where can I learn more about ArgoCD?
**A:**
- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [GitOps Principles](https://www.gitops.tech/)

---

## Still Have Questions?

- 📧 Email: support@example.com
- 🐛 GitHub Issues: [Report a bug](https://github.com/AndreLiar/templatecluster/issues)
- 💬 Discussions: [Ask the community](https://github.com/AndreLiar/templatecluster/discussions)
- 📚 Documentation: Check the `docs/` folder for detailed guides

---

**Pro Tip:** Start with the Quick Start guide in the README, deploy the dev environment, and explore the services. Learning by doing is the best way! 🚀
