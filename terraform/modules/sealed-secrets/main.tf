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

# Provider configurations are handled by the calling module

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "kube-system"

  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
}

output "kubeseal_install_cmd" {
  value = "brew install kubeseal"
}

output "usage_example" {
  value = <<-EOT
    # Create a sealed secret:
    kubectl create secret generic mysecret --from-literal=password=mypassword --dry-run=client -o yaml > secret.yaml
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format yaml < secret.yaml > sealed-secret.yaml
    kubectl apply -f sealed-secret.yaml
  EOT
}