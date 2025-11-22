# 🎓 Infrastructure Mastery Training Program

> **Customized for:** Beginner-Intermediate Level  
> **Goals:** Career Advancement & Team Training  
> **Schedule:** Weekdays, Hands-On Focused  
> **Duration:** 30 Days (6 weeks with weekends off)

---

## 👤 Your Profile

**Current Level:** Beginner-Intermediate  
**Learning Style:** Hands-on practice (70%), Theory (30%)  
**Goals:**
- Career advancement in DevOps/Platform Engineering
- Ability to train your team on this infrastructure

**Schedule:** Weekdays only (Monday-Friday)  
**Time Commitment:** 2-3 hours per day

---

## 🎯 Learning Objectives

By completing this program, you will:

1. ✅ **Master the Infrastructure** - Deploy, manage, and troubleshoot confidently
2. ✅ **Advance Your Career** - Gain skills for Platform Engineer/DevOps roles
3. ✅ **Train Your Team** - Become the go-to expert who can teach others
4. ✅ **Build Production Systems** - Create enterprise-grade infrastructure
5. ✅ **Earn Certifications** - Prepare for CKA/CKAD/Terraform Associate

---

## 📅 6-Week Training Schedule (Weekdays Only)

### **Week 1: Foundations & Environment Setup**

#### **Day 1 (Monday): Environment Setup & First Deployment**
**Time:** 2.5 hours

**Morning Session (1 hour):**
```bash
# Install prerequisites
# Windows (PowerShell as Administrator):
choco install docker-desktop kubectl k3d terraform

# Verify installations
docker --version
kubectl version --client
k3d version
terraform version
```

**Afternoon Session (1.5 hours):**
```bash
# Clone the repository
git clone https://github.com/AndreLiar/templatecluster.git
cd templatecluster

# Deploy your first cluster (minimal profile)
./scripts/create-cluster.sh dev minimal

# Explore the cluster
kubectl get nodes --context k3d-HDI-dev
kubectl get pods -A --context k3d-HDI-dev
kubectl get svc -A --context k3d-HDI-dev

# Access ArgoCD
# Open http://localhost:30200
# Get credentials: cat terraform/environments/dev/.credentials
```

**Learning Outcomes:**
- ✅ Environment fully set up
- ✅ First cluster deployed
- ✅ Comfortable with basic kubectl commands

**Homework:**
- Read: "What is Kubernetes?" (kubernetes.io/docs/concepts)
- Document: What you learned today in a personal notes file

---

#### **Day 2 (Tuesday): Understanding k3d & Docker**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Explore Docker containers
docker ps
docker stats

# See k3d cluster details
k3d cluster list
k3d node list

# Access a node directly
docker exec -it k3d-HDI-dev-server-0 sh
# Inside the container:
kubectl get nodes
exit

# Study the cluster configuration
cat terraform/modules/k3d-cluster/main.tf

# Modify cluster: Change agents from 2 to 3
# Edit: terraform/modules/k3d-cluster/main.tf
# Line: agents = 3

# Delete and recreate
k3d cluster delete HDI-dev
./scripts/create-cluster.sh dev minimal
```

**Learning Outcomes:**
- ✅ Understand k3d architecture
- ✅ Know the difference between control plane and worker nodes
- ✅ Can modify cluster configuration

**Homework:**
- Read: k3d documentation (k3d.io)
- Experiment: Try different cluster configurations

---

#### **Day 3 (Wednesday): Terraform Fundamentals**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# See what will be created (without creating)
terraform plan

# Apply changes
terraform apply

# Inspect the state
terraform show
terraform state list

# Make a change: Edit main.tf
# Change deployment_profile to "standard"

# See the diff
terraform plan

# Apply the change
terraform apply

# Destroy everything
terraform destroy
```

**Study These Files:**
1. `terraform/environments/dev/main.tf` - Main configuration
2. `terraform/environments/dev/variables.tf` - Input variables
3. `terraform/environments/dev/profiles.tf` - Deployment profiles
4. `terraform/modules/k3d-cluster/main.tf` - Cluster module

**Learning Outcomes:**
- ✅ Understand Terraform workflow (init, plan, apply, destroy)
- ✅ Can read and modify Terraform code
- ✅ Know what terraform.tfstate contains

**Homework:**
- Read: Terraform documentation (terraform.io/docs)
- Practice: Create a simple Terraform configuration from scratch

---

#### **Day 4 (Thursday): ArgoCD & GitOps**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Deploy standard profile (includes ArgoCD)
./scripts/create-cluster.sh dev standard

# Access ArgoCD UI
# http://localhost:30200
# Login: admin / (check .credentials file)

# Deploy the bootstrap application
kubectl apply -f kubernetes/argocd/bootstrap-app.yaml --context k3d-HDI-dev

# Watch ArgoCD sync
# In ArgoCD UI, observe the bootstrap app

# Create your own application
cat <<EOF > kubernetes/applications/my-first-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-nginx
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AndreLiar/templatecluster.git
    targetRevision: HEAD
    path: kubernetes/base/example
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

kubectl apply -f kubernetes/applications/my-first-app.yaml --context k3d-HDI-dev
```

**Study These Files:**
1. `terraform/modules/argocd/main.tf` - ArgoCD deployment
2. `kubernetes/argocd/bootstrap-app.yaml` - Bootstrap configuration
3. `kubernetes/applications/example-app.yaml` - Example application

**Learning Outcomes:**
- ✅ Understand GitOps principles
- ✅ Can deploy applications via ArgoCD
- ✅ Know how to troubleshoot sync issues

**Homework:**
- Read: ArgoCD documentation (argo-cd.readthedocs.io)
- Watch: "GitOps Explained" (YouTube)

---

#### **Day 5 (Friday): Kubernetes Deep Dive**
**Time:** 3 hours

**Hands-On Exercises:**
```bash
# Create a deployment manually
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF

# Watch pods being created
kubectl get pods -w --context k3d-HDI-dev

# Scale the deployment
kubectl scale deployment my-app --replicas=5 --context k3d-HDI-dev

# Expose as a service
kubectl expose deployment my-app --type=NodePort --port=80 --context k3d-HDI-dev

# Get the service
kubectl get svc my-app --context k3d-HDI-dev

# Describe the deployment
kubectl describe deployment my-app --context k3d-HDI-dev

# Check logs
kubectl logs -l app=my-app --context k3d-HDI-dev

# Delete a pod and watch it recreate
kubectl delete pod -l app=my-app --context k3d-HDI-dev | head -1
kubectl get pods -w --context k3d-HDI-dev

# Clean up
kubectl delete deployment my-app --context k3d-HDI-dev
kubectl delete svc my-app --context k3d-HDI-dev
```

**Learning Outcomes:**
- ✅ Understand Pods, Deployments, Services
- ✅ Can create and manage Kubernetes resources
- ✅ Know how to debug pod issues

**Weekend Assignment:**
- Read: Kubernetes concepts (pods, deployments, services, namespaces)
- Practice: Create different types of Kubernetes resources
- Reflect: Document your Week 1 learnings

---

### **Week 2: Monitoring, Networking & Security**

#### **Day 6 (Monday): Prometheus & Grafana**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Ensure you have standard profile deployed
./scripts/create-cluster.sh dev standard

# Access Grafana
# http://localhost:30300
# Login: admin / (check .credentials)

# Explore pre-built dashboards:
# 1. Kubernetes / Compute Resources / Cluster
# 2. Kubernetes / Compute Resources / Namespace (Pods)
# 3. Node Exporter / Nodes

# Access Prometheus
# http://localhost:30090

# Run PromQL queries:
up
kube_pod_info
node_memory_MemAvailable_bytes
rate(container_cpu_usage_seconds_total[5m])

# Create a custom dashboard in Grafana
# Add panels for:
# - Pod count
# - Memory usage
# - CPU usage
```

**Study These Files:**
1. `terraform/modules/monitoring/main.tf` - Monitoring stack
2. `terraform/modules/monitoring/values.yaml` - Prometheus configuration

**Learning Outcomes:**
- ✅ Can navigate Grafana dashboards
- ✅ Understand basic PromQL queries
- ✅ Know how to create custom dashboards

---

#### **Day 7 (Tuesday): NGINX Ingress Controller**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Create two different services
kubectl create deployment app1 --image=nginx:alpine --context k3d-HDI-dev
kubectl create deployment app2 --image=httpd:alpine --context k3d-HDI-dev

kubectl expose deployment app1 --port=80 --context k3d-HDI-dev
kubectl expose deployment app2 --port=80 --context k3d-HDI-dev

# Create an Ingress resource
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 80
EOF

# Test the ingress
curl -H "Host: myapp.local" http://localhost:30080/app1
curl -H "Host: myapp.local" http://localhost:30080/app2
```

**Study These Files:**
1. `terraform/modules/ingress/main.tf` - Ingress controller

**Learning Outcomes:**
- ✅ Understand Ingress concepts
- ✅ Can create path-based routing
- ✅ Know how to configure virtual hosts

---

#### **Day 8 (Wednesday): Cert-Manager & TLS**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Create a self-signed certificate
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app-tls
  namespace: default
spec:
  secretName: my-app-tls-secret
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
  dnsNames:
  - myapp.local
EOF

# Check certificate
kubectl get certificate --context k3d-HDI-dev
kubectl describe certificate my-app-tls --context k3d-HDI-dev

# Update Ingress to use TLS
# Add tls section to previous Ingress
```

**Study These Files:**
1. `terraform/modules/cert-manager/main.tf` - Cert-Manager deployment

**Learning Outcomes:**
- ✅ Understand certificate automation
- ✅ Can create and manage certificates
- ✅ Know how to configure TLS for Ingress

---

#### **Day 9 (Thursday): Sealed Secrets**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Install kubeseal CLI
# Windows: choco install kubeseal

# Create a regular secret
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  --dry-run=client -o yaml > my-secret.yaml

# Seal the secret
kubeseal --context k3d-HDI-dev < my-secret.yaml > my-sealed-secret.yaml

# Apply the sealed secret
kubectl apply -f my-sealed-secret.yaml --context k3d-HDI-dev

# Verify it was decrypted
kubectl get secret my-secret --context k3d-HDI-dev -o yaml

# Use the secret in a pod
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: v1
kind: Pod
metadata:
  name: secret-test
spec:
  containers:
  - name: test
    image: busybox
    command: ["sleep", "3600"]
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: password
EOF

# Verify
kubectl exec secret-test --context k3d-HDI-dev -- env | grep -E "USERNAME|PASSWORD"
```

**Study These Files:**
1. `terraform/modules/sealed-secrets/main.tf` - Sealed Secrets controller

**Learning Outcomes:**
- ✅ Understand secret encryption for GitOps
- ✅ Can create and use sealed secrets
- ✅ Know the security benefits

---

#### **Day 10 (Friday): Network Policies**
**Time:** 3 hours

**Hands-On Exercises:**
```bash
# Deploy full profile (includes network policies)
./scripts/create-cluster.sh dev full

# Create test pods
kubectl run frontend --image=nginx --context k3d-HDI-dev
kubectl run backend --image=nginx --context k3d-HDI-dev
kubectl run database --image=nginx --context k3d-HDI-dev

# Test connectivity (all should work initially)
kubectl exec frontend --context k3d-HDI-dev -- curl backend
kubectl exec frontend --context k3d-HDI-dev -- curl database

# Create a network policy (deny all)
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test connectivity (should fail now)
kubectl exec frontend --context k3d-HDI-dev -- curl backend

# Create selective allow policy
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  podSelector:
    matchLabels:
      run: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: frontend
EOF

# Test (frontend → backend should work, frontend → database should fail)
```

**Study These Files:**
1. `terraform/modules/network-policies/` - Network policy configurations

**Learning Outcomes:**
- ✅ Understand network security
- ✅ Can create network policies
- ✅ Know how to implement zero-trust networking

**Weekend Assignment:**
- Review Week 2 concepts
- Practice creating Ingress, Certificates, and Network Policies
- Document your learnings

---

### **Week 3: Advanced Kubernetes & Helm**

#### **Day 11 (Monday): Helm Charts Deep Dive**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Install Helm (if not already)
choco install kubernetes-helm

# Explore existing Helm releases
helm list -A --kube-context k3d-HDI-dev

# Get values for a release
helm get values argo-cd -n argocd --kube-context k3d-HDI-dev

# Create your own Helm chart
helm create my-app

# Explore the structure
cd my-app
# Edit values.yaml
# Edit templates/deployment.yaml

# Install your chart
helm install my-release ./my-app --kube-context k3d-HDI-dev

# Upgrade the release
# Edit values.yaml
helm upgrade my-release ./my-app --kube-context k3d-HDI-dev

# Rollback
helm rollback my-release 1 --kube-context k3d-HDI-dev

# Uninstall
helm uninstall my-release --kube-context k3d-HDI-dev
```

**Learning Outcomes:**
- ✅ Understand Helm vs raw YAML
- ✅ Can create Helm charts
- ✅ Know how to manage Helm releases

---

#### **Day 12 (Tuesday): Multi-Environment Management**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Deploy all three environments
./scripts/create-cluster.sh dev standard
./scripts/create-cluster.sh staging standard
./scripts/create-cluster.sh prod standard

# List all clusters
k3d cluster list

# Switch between contexts
kubectl config get-contexts
kubectl config use-context k3d-HDI-dev
kubectl config use-context k3d-HDI-stage
kubectl config use-context k3d-HDI-prod

# Deploy same app to all environments
kubectl apply -f my-app.yaml --context k3d-HDI-dev
kubectl apply -f my-app.yaml --context k3d-HDI-stage
kubectl apply -f my-app.yaml --context k3d-HDI-prod

# Compare environments
kubectl get pods -A --context k3d-HDI-dev
kubectl get pods -A --context k3d-HDI-stage
kubectl get pods -A --context k3d-HDI-prod
```

**Learning Outcomes:**
- ✅ Can manage multiple clusters
- ✅ Understand environment promotion
- ✅ Know how to switch contexts

---

#### **Day 13 (Wednesday): CI/CD with GitHub Actions**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Study the existing workflow
cat .github/workflows/terraform-ci.yml

# Create your own workflow
cat <<EOF > .github/workflows/deploy.yml
name: Deploy to Dev

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Deploy
        run: |
          kubectl apply -f kubernetes/base/example/ --context k3d-HDI-dev
EOF

# Commit and push
git add .github/workflows/deploy.yml
git commit -m "Add deployment workflow"
git push

# Watch the workflow run in GitHub Actions
```

**Learning Outcomes:**
- ✅ Understand CI/CD concepts
- ✅ Can create GitHub Actions workflows
- ✅ Know how to automate deployments

---

#### **Day 14 (Thursday): Troubleshooting & Debugging**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Intentionally break things and fix them

# 1. Create a pod with wrong image
kubectl run broken-pod --image=nonexistent:latest --context k3d-HDI-dev

# Debug it
kubectl describe pod broken-pod --context k3d-HDI-dev
kubectl logs broken-pod --context k3d-HDI-dev

# 2. Create a pod with resource limits too high
cat <<EOF | kubectl apply -f - --context k3d-HDI-dev
apiVersion: v1
kind: Pod
metadata:
  name: resource-hog
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "100Gi"
        cpu: "100"
EOF

# Debug it
kubectl describe pod resource-hog --context k3d-HDI-dev

# 3. Create a service pointing to wrong port
# Create deployment on port 80
# Create service pointing to port 8080
# Debug the connection issue

# 4. Use kubectl debug
kubectl debug broken-pod -it --image=busybox --context k3d-HDI-dev
```

**Learning Outcomes:**
- ✅ Can debug pod failures
- ✅ Know how to read logs and events
- ✅ Understand common issues and solutions

---

#### **Day 15 (Friday): Week 3 Project**
**Time:** 3 hours

**Project: Deploy a Complete Microservices Application**

**Requirements:**
1. 3 microservices (frontend, backend, database)
2. Ingress routing
3. TLS certificates
4. Network policies
5. Monitoring dashboards
6. GitOps deployment via ArgoCD

**Deliverables:**
- All YAML manifests
- ArgoCD Application definitions
- Custom Grafana dashboard
- Documentation

**Weekend Assignment:**
- Complete the project
- Document your architecture
- Prepare to present to your team

---

### **Week 4: Production Readiness**

#### **Day 16 (Monday): Resource Management & Autoscaling**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Create deployment with resource limits
# Add Horizontal Pod Autoscaler
# Load test and watch it scale
# Study resource quotas and limit ranges
```

---

#### **Day 17 (Tuesday): Backup & Disaster Recovery**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Backup cluster state
# Simulate disaster
# Restore from backup
# Document recovery procedures
```

---

#### **Day 18 (Wednesday): Security Hardening**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Implement RBAC
# Pod Security Policies
# Image scanning
# Security audit
```

---

#### **Day 19 (Thursday): Performance Tuning**
**Time:** 2.5 hours

**Hands-On Exercises:**
```bash
# Optimize resource usage
# Tune Prometheus retention
# Configure caching
# Load testing
```

---

#### **Day 20 (Friday): Week 4 Project**
**Time:** 3 hours

**Project: Production-Ready Platform**
- Multi-environment setup
- Full security implementation
- Monitoring and alerting
- Disaster recovery plan
- Complete documentation

---

### **Week 5-6: Mastery & Team Training**

#### **Days 21-25: Custom Extensions**
- Create custom Terraform modules
- Build custom Helm charts
- Design custom Grafana dashboards
- Develop custom ArgoCD applications

#### **Days 26-30: Team Training Preparation**
- Create training materials
- Build demo scenarios
- Write runbooks
- Prepare presentations

---

## 📚 Resources Provided

### **Documentation:**
- Component deep-dives (in `docs/`)
- Architecture explanations
- Best practices guides
- Troubleshooting playbooks

### **Hands-On Labs:**
- Daily exercises
- Weekly projects
- Real-world scenarios
- Challenge problems

---

## 🎯 Career Advancement Path

**After completing this program, you'll be qualified for:**

1. **Platform Engineer** ($120K-$180K)
2. **DevOps Engineer** ($110K-$160K)
3. **Site Reliability Engineer** ($130K-$200K)
4. **Cloud Architect** ($140K-$250K)

**Certifications to pursue:**
- CKA (Certified Kubernetes Administrator)
- CKAD (Certified Kubernetes Application Developer)
- Terraform Associate
- AWS/Azure/GCP certifications

---

## 👥 Team Training Approach

**By Week 6, you'll be able to train your team:**

1. **Beginner Track** (1 week)
   - Environment setup
   - Basic deployments
   - Monitoring basics

2. **Intermediate Track** (2 weeks)
   - GitOps workflows
   - Security implementation
   - Troubleshooting

3. **Advanced Track** (1 week)
   - Custom modules
   - Production optimization
   - Architecture design

---

## ✅ Success Checklist

**Week 1:**
- [ ] Environment fully set up
- [ ] Can deploy clusters confidently
- [ ] Understand basic Kubernetes concepts

**Week 2:**
- [ ] Can configure networking
- [ ] Implement security features
- [ ] Create monitoring dashboards

**Week 3:**
- [ ] Master Helm charts
- [ ] Manage multiple environments
- [ ] Debug complex issues

**Week 4:**
- [ ] Implement production best practices
- [ ] Create disaster recovery plans
- [ ] Optimize performance

**Week 5-6:**
- [ ] Build custom extensions
- [ ] Prepare team training
- [ ] Ready to lead infrastructure projects

---

## 🚀 Let's Begin!

**Your first task:**

1. **Today:** Set up your environment (Day 1 exercises)
2. **This week:** Complete Week 1 (Days 1-5)
3. **Document:** Keep a learning journal

**I'll be here to:**
- Answer all your questions
- Review your work
- Provide guidance
- Debug issues together

**Ready to start your journey to infrastructure mastery?** 🎉

Let's deploy your first cluster right now!
