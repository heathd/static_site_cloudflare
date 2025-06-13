variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "pool_id" {
  description = "The ID of the Workload Identity Pool"
  type        = string
  default     = "github-actions-pool"
}

variable "pool_display_name" {
  description = "The display name of the Workload Identity Pool"
  type        = string
  default     = "GitHub Actions Pool"
}

variable "pool_description" {
  description = "The description of the Workload Identity Pool"
  type        = string
  default     = "Identity pool for GitHub Actions"
}

variable "provider_id" {
  description = "The ID of the Workload Identity Pool Provider"
  type        = string
  default     = "github-actions-provider"
}

variable "provider_display_name" {
  description = "The display name of the Workload Identity Pool Provider"
  type        = string
  default     = "GitHub Actions Provider"
}

variable "allowed_audiences" {
  description = "List of allowed audiences for the OIDC provider"
  type        = list(string)
}

variable "service_account_id" {
  description = "The ID of the service account"
  type        = string
  default     = "github-actions-sa"
}

variable "service_account_display_name" {
  description = "The display name of the service account"
  type        = string
  default     = "GitHub Actions Service Account"
}

variable "github_repo" {
  description = "The GitHub repository in the format 'owner/repo'"
  type        = string
} 