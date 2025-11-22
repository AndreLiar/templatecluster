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
  environment = "staging"
  cluster_name = "HDI-stage"
  git_branch = "staging"

  ports = {
    http = "31080"
    https = "31443"
    grafana = "31300"
    prometheus = "31090"
    argocd = "31200"
    alertmanager = "31094"
  }
}

# Generate secure random passwords
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

# Store credentials in a local file (gitignored)
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
  
  cluster_context = module.k3d_cluster.context_name
  http_port = local.ports.http
  https_port = local.ports.https
  
  depends_on = [module.k3d_cluster]
}

module "monitoring" {
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