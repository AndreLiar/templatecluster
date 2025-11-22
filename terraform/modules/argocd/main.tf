terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

variable "cluster_context" {
  description = "Kubernetes cluster context"
  type        = string
}

variable "argocd_port" {
  description = "ArgoCD NodePort"
  type        = string
}

variable "admin_password" {
  description = "ArgoCD admin password"
  type        = string
  sensitive   = true
}

variable "git_repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "git_branch" {
  description = "Git branch to track"
  type        = string
}

variable "git_username" {
  description = "Git username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_password" {
  description = "Git password/token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Provider configurations are handled by the calling module

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.service.nodePortHttp"
    value = var.argocd_port
  }

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.admin_password)
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  set {
    name  = "server.service.nodePortHttps"
    value = ""
  }

  # ArgoCD Server resource limits
  set {
    name  = "server.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "512Mi"
  }

  # ArgoCD Repo Server resource limits
  set {
    name  = "repoServer.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "repoServer.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "repoServer.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "repoServer.resources.limits.memory"
    value = "512Mi"
  }

  # ArgoCD Application Controller resource limits
  set {
    name  = "controller.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  # ArgoCD Redis resource limits
  set {
    name  = "redis.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "redis.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "redis.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "redis.resources.limits.memory"
    value = "256Mi"
  }

  # ArgoCD Dex Server resource limits
  set {
    name  = "dex.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "dex.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "dex.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "dex.resources.limits.memory"
    value = "256Mi"
  }

  # ArgoCD ApplicationSet Controller resource limits
  set {
    name  = "applicationSet.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "applicationSet.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "applicationSet.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "applicationSet.resources.limits.memory"
    value = "256Mi"
  }

  # ArgoCD Notifications Controller resource limits
  set {
    name  = "notifications.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "notifications.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "notifications.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "notifications.resources.limits.memory"
    value = "256Mi"
  }

  timeout = 600
}

# Wait for ArgoCD to be ready
resource "null_resource" "wait_for_argocd" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s --context=${var.cluster_context}"
  }
}

# Git repository secret
resource "kubernetes_secret" "git_repo" {
  depends_on = [null_resource.wait_for_argocd]

  metadata {
    name      = "git-repo-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.git_repo_url
    username      = var.git_username
    password      = var.git_password
    project       = "default"
  }
}

# Application of Applications (App of Apps)
resource "helm_release" "app_of_apps" {
  depends_on = [kubernetes_secret.git_repo]

  name       = "app-of-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<-EOT
    applications:
      - name: root-app
        namespace: argocd
        project: default
        source:
          repoURL: ${var.git_repo_url}
          targetRevision: ${var.git_branch}
          path: kubernetes/base
        destination:
          server: https://kubernetes.default.svc
          namespace: default
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
    EOT
  ]
}

output "argocd_url" {
  value = "http://localhost:${var.argocd_port}"
}