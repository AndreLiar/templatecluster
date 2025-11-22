# Allow Monitoring Ingress
resource "kubernetes_network_policy" "allow_monitoring" {
  metadata {
    name      = "allow-monitoring"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "prometheus"
      }
    }
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
    }
  }
}

# Allow Ingress Controller
resource "kubernetes_network_policy" "allow_ingress" {
  metadata {
    name      = "allow-ingress"
    namespace = var.namespace
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "ingress-nginx"
          }
        }
      }
    }
  }
}
