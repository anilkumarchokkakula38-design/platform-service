# README - Terraform Module Documentation

This directory contains the Terraform configuration for deploying the Platform Service to Google Cloud Run.

## Structure

```
terraform/
├── modules/
│   └── cloud_run/        # Reusable Cloud Run module
├── dev/                  # Dev environment configuration
├── prod/                 # Prod environment configuration
└── README.md
```

## Module Overview

### cloud_run Module

Encapsulates Cloud Run service deployment with:
- Service configuration with custom resource allocation
- Service account with least-privilege IAM
- Health checks (liveness and startup probes)
- Auto-scaling configuration
- Structured outputs

## Environment Configuration

### Dev Environment
- CPU: 0.25
- Memory: 128Mi
- Min instances: 0 (scales to zero)
- Max instances: 5

### Prod Environment
- CPU: 0.5
- Memory: 256Mi
- Min instances: 1 (always running)
- Max instances: 20

## Usage

### Prerequisites

1. Install Terraform >= 1.0
2. Install Google Cloud SDK
3. Authenticate: `gcloud auth application-default login`
4. Set project: `gcloud config set project YOUR_PROJECT_ID`

### Deploy Dev Environment

```bash
cd terraform/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### Deploy Prod Environment

```bash
cd terraform/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### Validate Configuration

```bash
# Format check
terraform fmt -recursive -check terraform/

# Validation
cd terraform/dev && terraform validate
cd ../prod && terraform validate
```

## IAM Permissions Required

The service account running Terraform requires:
- `roles/run.admin` - Full Cloud Run management
- `roles/iam.securityAdmin` - Service account and IAM binding management
- `roles/logging.admin` - Logging permissions (optional, for service account)

## Clean Up

```bash
# Destroy dev environment
cd terraform/dev && terraform destroy

# Destroy prod environment
cd terraform/prod && terraform destroy
```

## Outputs

Each environment configuration outputs:
- `service_url` - The public URL of the deployed service
- `service_name` - The Cloud Run service name

Access outputs after deployment:
```bash
terraform output
terraform output service_url
```

## Notes

- Each environment has its own Terraform state (dev/ and prod/)
- Service accounts are created per environment with least-privilege IAM
- Health checks ensure service health is continuously monitored
- Memory and CPU are pre-sized per environment; adjust in main.tf if needed
- All resources are tagged with environment and managed-by labels
