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

  timeout = 600
}

# Wait for ArgoCD to be ready
resource "null_resource" "wait_for_argocd" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server \
        -n argocd --timeout=300s --context=${var.cluster_context}
    EOT
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

  data = merge(
    {
      type = "git"
      url  = var.git_repo_url
    },
    var.git_username != "" ? { username = var.git_username } : {},
    var.git_password != "" ? { password = var.git_password } : {}
  )
}

output "argocd_url" {
  value = "http://localhost:${var.argocd_port}"
}

output "argocd_credentials" {
  value = {
    username = "admin"
    password = var.admin_password
  }
  sensitive = true
}