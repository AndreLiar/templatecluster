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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

locals {
  environment = "dev"
  cluster_name = "HDI-dev"
  git_branch = "dev"

  ports = {
    http = "30080"
    https = "30443"
    grafana = "30300"
    prometheus = "30090"
    argocd = "30200"
    alertmanager = "30094"
  }
}

resource "random_password" "argocd_admin" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "grafana_admin" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_file" "credentials" {
  filename        = "${path.module}/.credentials"
  content         = <<-EOT
    # ${local.cluster_name} Credentials
    # Generated: ${timestamp()}
    # IMPORTANT: Keep this file secure and do not commit to Git

    ## ArgoCD
    URL: http://localhost:${local.ports.argocd}
    Username: admin
    Password: ${random_password.argocd_admin.result}

    ## Grafana
    URL: http://localhost:${local.ports.grafana}
    Username: admin
    Password: ${random_password.grafana_admin.result}

    ## Access All Services
    ArgoCD:       http://localhost:${local.ports.argocd}
    Grafana:      http://localhost:${local.ports.grafana}
    Prometheus:   http://localhost:${local.ports.prometheus}
    Alertmanager: http://localhost:${local.ports.alertmanager}
    HTTP:         http://localhost:${local.ports.http}
    HTTPS:        https://localhost:${local.ports.https}
  EOT
  file_permission = "0600"
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
  depends_on = [module.k3d_cluster]

  cluster_context = module.k3d_cluster.context_name
  http_port       = local.ports.http
  https_port      = local.ports.https
}

module "monitoring" {
  source = "../../modules/monitoring"
  count  = local.active_profile.monitoring ? 1 : 0
  depends_on = [module.k3d_cluster]

  cluster_context   = module.k3d_cluster.context_name
  grafana_port      = local.ports.grafana
  prometheus_port   = local.ports.prometheus
  alertmanager_port = local.ports.alertmanager
  grafana_password  = random_password.grafana_admin.result
}

module "argocd" {
  source = "../../modules/argocd"
  depends_on = [module.k3d_cluster]

  cluster_context = module.k3d_cluster.context_name
  argocd_port     = local.ports.argocd
  admin_password  = random_password.argocd_admin.result
  environment     = local.environment
  
  git_repo_url = var.git_repo_url
  git_branch   = local.git_branch
  git_username = var.git_username
  git_password = var.git_password
}

module "sealed_secrets" {
  source = "../../modules/sealed-secrets"
  count  = local.active_profile.sealed_secrets ? 1 : 0
  depends_on = [module.k3d_cluster]

  cluster_context = module.k3d_cluster.context_name
}

module "cert_manager" {
  source = "../../modules/cert-manager"
  count  = local.active_profile.cert_manager ? 1 : 0
  depends_on = [module.k3d_cluster]

  cluster_context = module.k3d_cluster.context_name
}

module "network_policies" {
  source = "../../modules/network-policies"
  count  = local.active_profile.network_policies ? 1 : 0
  depends_on = [module.k3d_cluster]

  namespace = "default"
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
    grafana = length(module.monitoring) > 0 ? module.monitoring[0].grafana_url : "Disabled"
    prometheus = length(module.monitoring) > 0 ? module.monitoring[0].prometheus_url : "Disabled"
    alertmanager = length(module.monitoring) > 0 ? module.monitoring[0].alertmanager_url : "Disabled"
    argocd = module.argocd.argocd_url
  }
}

output "credentials" {
  value = {
    grafana = {
      username = "admin"
      password = random_password.grafana_admin.result
    }
    argocd = {
      username = "admin"
      password = random_password.argocd_admin.result
    }
    credentials_file = "Credentials saved to: ${abspath(local_file.credentials.filename)}"
  }
  sensitive = true
}