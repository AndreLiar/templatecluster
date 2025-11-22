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