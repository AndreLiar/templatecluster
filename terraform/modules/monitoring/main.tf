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

variable "grafana_port" {
  description = "Grafana NodePort"
  type        = string
}

variable "prometheus_port" {
  description = "Prometheus NodePort"
  type        = string
}

variable "alertmanager_port" {
  description = "AlertManager NodePort"
  type        = string
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  default     = "enterprise123"
  sensitive   = true
}

# Provider configurations are handled by the calling module

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  set {
    name  = "grafana.service.type"
    value = "NodePort"
  }

  set {
    name  = "grafana.service.nodePort"
    value = var.grafana_port
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }

  set {
    name  = "prometheus.service.type"
    value = "NodePort"
  }

  set {
    name  = "prometheus.service.nodePort"
    value = var.prometheus_port
  }

  set {
    name  = "alertmanager.service.type"
    value = "NodePort"
  }

  set {
    name  = "alertmanager.service.nodePort"
    value = var.alertmanager_port
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  timeout = 600
}

output "grafana_url" {
  value = "http://localhost:${var.grafana_port}"
}

output "prometheus_url" {
  value = "http://localhost:${var.prometheus_port}"
}

output "alertmanager_url" {
  value = "http://localhost:${var.alertmanager_port}"
}