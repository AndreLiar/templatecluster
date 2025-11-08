terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

variable "cluster_name" {
  description = "Name of the k3d cluster"
  type        = string
}

variable "http_port" {
  description = "HTTP port for ingress"
  type        = string
}

variable "https_port" {
  description = "HTTPS port for ingress"
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

variable "argocd_port" {
  description = "ArgoCD NodePort"
  type        = string
}

variable "alertmanager_port" {
  description = "AlertManager NodePort"
  type        = string
}

resource "null_resource" "create_cluster" {
  provisioner "local-exec" {
    command = <<-EOT
      k3d cluster create ${var.cluster_name} \
        --servers 1 \
        --agents 2 \
        --port "${var.http_port}:80@loadbalancer" \
        --port "${var.https_port}:443@loadbalancer" \
        --port "${var.grafana_port}:${var.grafana_port}@loadbalancer" \
        --port "${var.prometheus_port}:${var.prometheus_port}@loadbalancer" \
        --port "${var.argocd_port}:${var.argocd_port}@loadbalancer" \
        --port "${var.alertmanager_port}:${var.alertmanager_port}@loadbalancer" \
        --wait
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name} || true"
  }

  triggers = {
    cluster_name = var.cluster_name
  }
}

resource "null_resource" "kubeconfig_merge" {
  depends_on = [null_resource.create_cluster]
  
  provisioner "local-exec" {
    command = "k3d kubeconfig merge ${var.cluster_name} --kubeconfig-merge-default"
  }
}

output "cluster_name" {
  value = var.cluster_name
}

output "context_name" {
  value = "k3d-${var.cluster_name}"
}