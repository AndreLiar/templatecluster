# 📦 Helm vs YAML: Package Management Explained

## Your Observation is Correct! ✅

You noticed that the project uses **both Helm and raw Kubernetes YAML**, but in different places. Let me explain the architecture.

---

## 🎯 What's Actually Used

### **1. Helm Charts (via Terraform)** - Infrastructure Components

**All major infrastructure components are deployed using Helm:**

| Component | Helm Chart | Repository |
|-----------|------------|------------|
| **ArgoCD** | `argo-cd` | https://argoproj.github.io/argo-helm |
| **Prometheus + Grafana** | `kube-prometheus-stack` | https://prometheus-community.github.io/helm-charts |
| **NGINX Ingress** | `ingress-nginx` | https://kubernetes.github.io/ingress-nginx |
| **Cert-Manager** | `cert-manager` | https://charts.jetstack.io |
| **Sealed Secrets** | `sealed-secrets` | https://bitnami-labs.github.io/sealed-secrets |

**How it works:**

```hcl
# terraform/modules/argocd/main.tf
resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
}
```

**Why Helm for infrastructure:**
- ✅ Battle-tested charts from official repositories
- ✅ Easy configuration via `set` blocks
- ✅ Automatic upgrades
- ✅ Dependency management
- ✅ Community support

---

### **2. Raw Kubernetes YAML** - Application Layer

**User applications and ArgoCD configurations use raw YAML:**

```
kubernetes/
├── argocd/
│   └── bootstrap-app.yaml          # ArgoCD Application (raw YAML)
├── applications/
│   └── example-app.yaml            # ArgoCD Application (raw YAML)
└── base/
    └── example/
        └── nginx-demo.yaml         # Sample deployment (raw YAML)
```

**Example:**
```yaml
# kubernetes/argocd/bootstrap-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AndreLiar/templatecluster.git
    targetRevision: HEAD
    path: kubernetes/applications
```

**Why raw YAML for applications:**
- ✅ Simplicity for custom apps
- ✅ GitOps-friendly
- ✅ No Helm chart needed for simple deployments
- ✅ Direct control over resources

---

## 🏗️ Architecture Breakdown

```
┌─────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                   │
│                  (Deployed via Helm)                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Terraform → helm_release → Helm Charts                │
│                                                         │
│  ✅ ArgoCD (Helm)                                      │
│  ✅ Prometheus (Helm)                                  │
│  ✅ Grafana (Helm)                                     │
│  ✅ NGINX Ingress (Helm)                               │
│  ✅ Cert-Manager (Helm)                                │
│  ✅ Sealed Secrets (Helm)                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Application Layer                      │
│              (Raw Kubernetes YAML)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Git → ArgoCD → kubectl apply → Kubernetes             │
│                                                         │
│  📄 ArgoCD Applications (YAML)                         │
│  📄 Custom Deployments (YAML)                          │
│  📄 Services (YAML)                                    │
│  📄 ConfigMaps (YAML)                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Comparison: What Uses What

### **Helm Charts (via Terraform)**

**Files:**
```
terraform/modules/
├── argocd/main.tf           → helm_release "argocd"
├── monitoring/main.tf       → helm_release "prometheus_stack"
├── ingress/main.tf          → helm_release "nginx_ingress"
├── cert-manager/main.tf     → helm_release "cert_manager"
└── sealed-secrets/main.tf   → helm_release "sealed_secrets"
```

**Advantages:**
- Managed by Terraform
- Version controlled
- Repeatable deployments
- Infrastructure as Code
- Easy rollback

---

### **Raw Kubernetes YAML**

**Files:**
```
kubernetes/
├── argocd/bootstrap-app.yaml
├── applications/example-app.yaml
└── base/example/nginx-demo.yaml
```

**Advantages:**
- Simple and direct
- GitOps-friendly
- No Helm complexity
- Easy to understand
- Full control

---

## 🤔 Why This Hybrid Approach?

### **Best of Both Worlds**

**Helm for Infrastructure:**
```
Complex components with many configurations
↓
Use battle-tested Helm charts
↓
Configure via Terraform
↓
Automated, repeatable, version-controlled
```

**YAML for Applications:**
```
Custom applications
↓
Simple Kubernetes manifests
↓
Managed by ArgoCD (GitOps)
↓
Direct, simple, flexible
```

---

## 💡 Real-World Example

### **Deploying Infrastructure (Helm)**

```hcl
# terraform/modules/monitoring/main.tf
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "45.7.1"
  
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
  
  set {
    name  = "prometheus.service.type"
    value = "NodePort"
  }
}
```

**Result:** Deploys 20+ Kubernetes resources (Prometheus, Grafana, Alertmanager, exporters, etc.)

---

### **Deploying Application (YAML)**

```yaml
# kubernetes/base/example/nginx-demo.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
```

**Result:** Simple nginx deployment

---

## 🔄 How They Work Together

```
1. Terraform deploys infrastructure (Helm)
   ↓
2. ArgoCD is now running (deployed via Helm)
   ↓
3. ArgoCD watches Git repository
   ↓
4. You push YAML manifests to Git
   ↓
5. ArgoCD automatically deploys them
   ↓
6. Your applications run on infrastructure deployed by Helm
```

---

## 📋 Summary Table

| Aspect | Helm (Infrastructure) | YAML (Applications) |
|--------|----------------------|---------------------|
| **What** | ArgoCD, Prometheus, Grafana, Ingress, Cert-Manager | Custom apps, ArgoCD Applications |
| **How** | Terraform `helm_release` | kubectl apply / ArgoCD |
| **Why** | Complex, battle-tested charts | Simple, custom deployments |
| **Managed By** | Terraform | Git + ArgoCD (GitOps) |
| **Configuration** | `set` blocks in Terraform | YAML files in Git |
| **Updates** | `terraform apply` | Git push → ArgoCD sync |

---

## 🎯 When to Use What

### **Use Helm When:**
- ✅ Deploying complex infrastructure (Prometheus, Grafana, etc.)
- ✅ Need battle-tested configurations
- ✅ Want easy upgrades
- ✅ Managing via Terraform

### **Use Raw YAML When:**
- ✅ Deploying custom applications
- ✅ Simple deployments
- ✅ GitOps workflow
- ✅ Full control needed

---

## 🚀 How to Add Your Own Components

### **Option 1: Add Helm Chart (Infrastructure)**

1. Create new Terraform module:
```hcl
# terraform/modules/my-component/main.tf
resource "helm_release" "my_component" {
  name       = "my-component"
  repository = "https://charts.example.com"
  chart      = "my-component"
  namespace  = "my-namespace"
}
```

2. Call from environment:
```hcl
# terraform/environments/dev/main.tf
module "my_component" {
  source = "../../modules/my-component"
}
```

---

### **Option 2: Add YAML Manifest (Application)**

1. Create YAML file:
```yaml
# kubernetes/base/my-app/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  # ... deployment spec
```

2. Create ArgoCD Application:
```yaml
# kubernetes/applications/my-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  source:
    path: kubernetes/base/my-app
```

3. Push to Git → ArgoCD deploys automatically!

---

## ✅ Conclusion

**Your observation is correct!** The project uses:

1. **Helm (via Terraform)** for infrastructure components
   - ArgoCD, Prometheus, Grafana, Ingress, Cert-Manager, Sealed Secrets
   - Managed by Terraform
   - Battle-tested charts

2. **Raw Kubernetes YAML** for applications
   - Custom deployments
   - ArgoCD Applications
   - Managed by GitOps

**This is a best practice!** 
- Use Helm for complex infrastructure
- Use YAML for simple applications
- Get the best of both worlds

**The template is actually MORE sophisticated than pure YAML or pure Helm!** 🎉
