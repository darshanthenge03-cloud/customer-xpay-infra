# XPay Azure Infrastructure (Terraform)

This repository deploys secure, production-grade Azure infrastructure using reusable Terraform modules.

## Architecture Overview

- Private VMs (no public IPs)
- Azure Bastion for secure access
- Managed Identity for Azure access
- Azure Key Vault for secrets
- Azure Backup with instant restore
- Modular Terraform design

## Repositories

### 1. terraform-azure-modules (Common)
Reusable platform modules:
- network
- vm (Linux + Windows)
- keyvault
- bastion
- backup

### 2. customer-xpay-infra (This Repo)
Environment-specific wiring only.
No Azure resources are created directly here.

## Security Design

- No VM public IPs
- SSH password authentication disabled
- Bastion-only access
- Secrets stored in Key Vault
- VM uses Managed Identity
- Backup enabled with 5-day instant restore

## Deployment

```bash
terraform init
terraform plan
terraform apply