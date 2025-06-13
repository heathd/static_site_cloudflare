# GCP OAuth Terraform Setup

This Terraform configuration will create a Google OAuth client for your Cloudflare Worker.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed
- Google Cloud account and project
- `gcloud` CLI authenticated (or set up a service account key)

## Usage

1. Edit `variables.tf` or provide variables via CLI or a `terraform.tfvars` file:
   - `project_id`: Your GCP project ID
   - `region`: GCP region (default: us-central1)
   - `support_email`: Email for OAuth consent screen

2. Initialize and apply:
   ```sh
   cd gcp-oauth-terraform
   terraform init
   terraform apply
   ```

3. The outputs will include your OAuth client ID and secret.

4. Add the following redirect URI to your OAuth client in the Google Cloud Console if needed:
   - `https://auth-worker.david-6f5.workers.dev/callback`

## Notes
- You may need to manually configure the OAuth consent screen in the Google Cloud Console the first time.
- For more advanced use cases, see the [Terraform Google Provider docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client). 