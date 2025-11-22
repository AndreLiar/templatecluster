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

variable "http_port" {
  description = "HTTP NodePort"
  type        = string
}

variable "https_port" {
  description = "HTTPS NodePort"
  type        = string
}

# Provider configurations are handled by the calling module

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = var.http_port
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = var.https_port
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "false"
  }

  # NGINX Ingress Controller resource limits
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "256Mi"
  }

  # Admission Webhook resource limits
  set {
    name  = "controller.admissionWebhooks.patch.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "controller.admissionWebhooks.patch.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "controller.admissionWebhooks.patch.resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "controller.admissionWebhooks.patch.resources.limits.memory"
    value = "128Mi"
  }

  # Default backend resource limits (if enabled)
  set {
    name  = "defaultBackend.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "defaultBackend.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = "true"
  }
}

output "https_url" {
  value = "https://localhost:${var.https_port}"
}
output "http_url" {
  value = "http://localhost:${var.http_port}"
}