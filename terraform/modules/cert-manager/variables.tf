variable "namespace" {
  description = "Namespace to install cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "chart_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.13.0"
}

variable "cluster_context" {
  description = "Kubernetes cluster context"
  type        = string
}
