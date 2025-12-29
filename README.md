# XPay Azure Infrastructure (Terraform)

This repository deploys secure, production-grade Azure infrastructure using reusable Terraform platform modules.

It represents a customer-specific implementation of a standardized Azure platform.


## Architecture Overview

This deployment follows a security-first and platform-driven design:

- Virtual machines run in private subnets
- No public IPs on workloads
- Azure Bastion used for secure access
- Managed Identity used for Azure service authentication
- Secrets stored in Azure Key Vault
- Azure Backup enabled with instant restore


## Architecture Diagram

![Architecture Diagram](docs/architecture.png)


## Deployed Components

- Virtual Network with public and private subnets
- Azure Bastion host
- Linux Virtual Machine (private subnet)
- Azure Key Vault
- Azure Backup (Recovery Services Vault)
- Daily VM backups with 5-day instant snapshot restore


## Security Design

- Zero public exposure for virtual machines
- SSH password authentication disabled
- Bastion-only administrative access
- Managed Identity for VM-to-Azure communication
- Centralized secret management
- Automated and enforced backups


## Infrastructure Automation

Infrastructure is deployed using Terraform and automated via GitHub Actions.

### CI/CD Flow
1. Code pushed to main branch
2. GitHub Actions runs Terraform
3. Infrastructure is planned and applied automatically
4. Azure environment is updated consistently


## Repository Structure

customer-xpay-infra/
├── env/
│ └── dev/
│ ├── main.tf
│ ├── variables.tf
│ ├── terraform.tfvars
│ └── backend.tf
├── .github/
│ └── workflows/
│ └── terraform.yml
├── docs/
│ └── architecture.png
└── README.md


## Deployment

- terraform init
- terraform plan
- terraform apply

State is stored remotely using Azure Storage with locking enabled.

## Access Model
- VM access via Azure Bastion
- No inbound internet access
- No exposed SSH or RDP ports

## Backup Strategy
- Daily backups at scheduled time
- 7-day retention
- 5-day instant snapshot restore for fast recovery
