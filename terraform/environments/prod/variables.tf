variable "argocd_admin_password" {
  description = "Admin password for ArgoCD"
  type        = string
  sensitive   = true
  default     = "Nightagent2025@"
}

variable "git_repo_url" {
  description = "Git repository URL"
  type        = string
  default     = "https://github.com/AndreLiar/KtaylBusiness"
}

variable "git_username" {
  description = "Git username for repository access"
  type        = string
  default     = "AndreLiar"
  sensitive   = true
}

variable "git_password" {
  description = "Git PAT token for repository access"
  type        = string
  default     = ""
  sensitive   = true
}