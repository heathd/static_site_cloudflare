variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

variable "support_email" {
  description = "Support email for OAuth consent screen."
  type        = string
} 