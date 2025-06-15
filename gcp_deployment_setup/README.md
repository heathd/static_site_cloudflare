# GCP Deployment Setup

This directory contains Terraform configuration to enable Workload Identity Federation in Google Cloud Platform (GCP) infrastructure. This allows GitHub Actions to deploy/operate on GCP resources.

## Purpose

The configuration in this directory:
1. Sets up [Workload Identity Federation] for secure authentication between [GitHub Actions] and GCP
2. Creates necessary service accounts and IAM permissions
3. Enables required GCP APIs
4. Configures GitHub Actions to deploy infrastructure changes

## Configuration Files

- `main.tf`: Main Terraform configuration including Workload Identity Federation setup
- `variables.tf`: Input variables for the Terraform configuration
- `terraform.tfvars`: Values for the input variables
- `outputs.tf`: Output values from the Terraform configuration

## Required GitHub Secrets

The following secrets need to be configured in your GitHub repository's GCP environment:

- `WIF_PROVIDER`: Full Workload Identity Provider resource name
- `WIF_SERVICE_ACCOUNT`: Service account email for GitHub Actions

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review changes:
   ```bash
   terraform plan
   ```

3. Apply changes:
   ```bash
   terraform apply
   ```

## Security

This setup uses Workload Identity Federation instead of service account keys, providing a more secure authentication method between GitHub Actions and GCP. The configuration:
- Uses short-lived tokens
- Implements least privilege access
- Avoids storing sensitive credentials in the repository

## GitHub Actions Integration

The GitHub Actions workflow in `.github/workflows/terraform.yml` uses this configuration to:
1. Authenticate with GCP using Workload Identity Federation
2. Run Terraform commands
3. Apply infrastructure changes on merge to main
4. Create pull request comments with plan details 


## References

- [Workload Identity Federation]
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Google Cloud IAM](https://cloud.google.com/iam/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

[Workload Identity Federation]: https://cloud.google.com/iam/docs/workload-identity-federation
