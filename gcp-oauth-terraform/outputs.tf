output "oauth_client_id" {
  value = google_iap_client.worker_oauth.client_id
}

output "oauth_client_secret" {
  value     = google_iap_client.worker_oauth.secret
  sensitive = true
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
  description = "The Workload Identity Provider resource name"
}

output "service_account_email" {
  value = google_service_account.github_actions.email
  description = "The service account email for GitHub Actions"
} 