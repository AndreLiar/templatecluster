variable "deployment_profile" {
  description = "Deployment profile: minimal, standard, full"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["minimal", "standard", "full"], var.deployment_profile)
    error_message = "Profile must be minimal, standard, or full"
  }
}

locals {
  profile_config = {
    minimal = {
      monitoring       = false
      sealed_secrets   = false
      cert_manager     = false
      network_policies = false
    }
    standard = {
      monitoring       = true
      sealed_secrets   = true
      cert_manager     = true
      network_policies = false
    }
    full = {
      monitoring       = true
      sealed_secrets   = true
      cert_manager     = true
      network_policies = true
    }
  }

  active_profile = local.profile_config[var.deployment_profile]
}
