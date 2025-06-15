terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
  depends_on = [google_project_service.iam]
}

# Workload Identity Federation configuration for GitHub Actions
resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = var.pool_id
  display_name              = var.pool_display_name
  description              = var.pool_description
  project                  = var.project_id
  depends_on = [google_project_service.iamcredentials]
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = var.provider_display_name
  project                           = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    allowed_audiences = [
      "https://github.com/${var.github_repo}",
      "//iam.googleapis.com/projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}/providers/${var.provider_id}"
    ]
    issuer_uri       = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "attribute.repository == '${var.github_repo}'"
}

resource "google_service_account" "github_actions" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  project      = var.project_id
  depends_on = [google_project_service.iam]
}

resource "google_service_account_iam_member" "github_actions_workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.github_repo}"
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "github_actions_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant service account token creator role
resource "google_service_account_iam_member" "github_actions_token_creator" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.github_repo}"
}

# Grant service account user role
resource "google_service_account_iam_member" "github_actions_service_account_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.serviceAccountUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.github_repo}"
}

# Grant Service Usage Admin role to enable APIs
resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
} 