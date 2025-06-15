output "oauth_client_id" {
  value = google_iap_client.worker_oauth.client_id
}

output "oauth_client_secret" {
  value     = google_iap_client.worker_oauth.secret
  sensitive = true
}
