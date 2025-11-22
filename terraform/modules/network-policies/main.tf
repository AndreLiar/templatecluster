resource "kubernetes_namespace" "network_policies" {
  metadata {
    name = var.namespace
  }
}

# Default Deny All Ingress
resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name      = "default-deny-all"
    namespace = var.namespace
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# Allow DNS
resource "kubernetes_network_policy" "allow_dns" {
  metadata {
    name      = "allow-dns"
    namespace = var.namespace
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]

    egress {
      to {
        namespace_selector {
          match_labels = {
            name = "kube-system"
          }
        }
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }
}
