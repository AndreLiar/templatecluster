terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
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

# Configure providers for all modules
# Note: These providers will connect to the cluster after it's created
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-${local.cluster_name}"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-${local.cluster_name}"
  }
}

locals {
  environment = "prod"
  cluster_name = "ktayl-${local.environment}"
  git_branch = "main"
  
  ports = {
    http = "32080"
    https = "32443"
    grafana = "32300"
    prometheus = "32090"
    argocd = "32200"
    alertmanager = "32094"
  }
}

module "k3d_cluster" {
  source = "../../modules/k3d-cluster"
  
  cluster_name = local.cluster_name
  http_port = local.ports.http
  https_port = local.ports.https
  grafana_port = local.ports.grafana
  prometheus_port = local.ports.prometheus
  argocd_port = local.ports.argocd
  alertmanager_port = local.ports.alertmanager
}

module "ingress" {
  source = "../../modules/ingress"
  
  cluster_context = module.k3d_cluster.context_name
  http_port = local.ports.http
  https_port = local.ports.https
  
  depends_on = [module.k3d_cluster]
}

module "monitoring" {
  source = "../../modules/monitoring"
  
  cluster_context = module.k3d_cluster.context_name
  grafana_port = local.ports.grafana
  prometheus_port = local.ports.prometheus
  alertmanager_port = local.ports.alertmanager
  
  depends_on = [module.k3d_cluster]
}

module "sealed_secrets" {
  source = "../../modules/sealed-secrets"
  
  cluster_context = module.k3d_cluster.context_name
  
  depends_on = [module.k3d_cluster]
}

module "argocd" {
  source = "../../modules/argocd"
  
  cluster_context = module.k3d_cluster.context_name
  argocd_port = local.ports.argocd
  admin_password = var.argocd_admin_password
  git_repo_url = var.git_repo_url
  git_branch = local.git_branch
  git_username = var.git_username
  git_password = var.git_password
  environment = local.environment
  
  depends_on = [module.k3d_cluster]
}

output "cluster_info" {
  value = {
    name = local.cluster_name
    context = module.k3d_cluster.context_name
    environment = local.environment
    git_branch = local.git_branch
  }
}

output "access_urls" {
  value = {
    nginx_http = module.ingress.http_url
    nginx_https = module.ingress.https_url
    grafana = module.monitoring.grafana_url
    prometheus = module.monitoring.prometheus_url
    alertmanager = module.monitoring.alertmanager_url
    argocd = module.argocd.argocd_url
  }
}

output "credentials" {
  value = {
    grafana = {
      username = "admin"
      password = "enterprise123"
    }
    argocd = module.argocd.argocd_credentials
  }
  sensitive = true
}