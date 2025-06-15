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

resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "oauth2" {
  project = var.project_id
  service = "oauth2.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

# Enable Identity-Aware Proxy API
resource "google_project_service" "iap" {
  project = var.project_id
  service = "iap.googleapis.com"
  depends_on = [google_project_service.iam]
}

resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
}

resource "google_iap_brand" "default" {
  support_email     = var.support_email
  application_title = "Cloudflare Worker OAuth"
  project           = var.project_id
}

resource "google_iap_client" "worker_oauth" {
  brand        = google_iap_brand.default.name
  display_name = "Cloudflare Worker OAuth Client"
}

# Note: For most OAuth use cases, you may want to use google_iap_client or google_oauth_client (beta)
# If you need a more general OAuth client, you may want to use the beta provider or create it manually in the console. 