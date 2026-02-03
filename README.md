# Traific: Geospatial Traffic Management Platform

[![Project Architecture](https://img.shields.io/badge/Architecture-AWS-orange)](docs/architecture_overview.md)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-Terraform-blue)](terraform/)
[![Configuration](https://img.shields.io/badge/Automation-Ansible-red)](ansible/)

Traific is a scalable, reproducible AWS-based platform designed for ingesting, processing, and analyzing geospatial traffic data. Purpose-built for the University of Melbourne Transport department, it leverages modern cloud-native technologies to handle intensive AI workloads and complex spatial queries.

## 🏗️ Architecture Overview

The platform is built on a robust AWS foundation:
- **Compute**: [Amazon EKS](terraform/eks.tf) for orchestrating AI models and API services.
- **Database**: [Amazon RDS (PostgreSQL)](terraform/rds.tf) with **PostGIS** for geospatial data management.
- **Storage**: [Amazon S3](terraform/s3.tf) serving as a scalable Data Lake.
- **Network**: Secure [VPC](terraform/vpc.tf) with public/private subnet isolation and NAT gateways.

Detailed documentation can be found in [Architecture Overview](docs/architecture_overview.md).

## 📂 Project Structure

```text
traific/
├── ansible/          # Ansible playbooks and inventories
├── docs/             # Technical documentation and diagrams
├── terraform/         # AWS Infrastructure as Code
└── README.md         # Project entry point
```

## 🚀 Quick Start

### 1. Provision Infrastructure
Navigate to the terraform directory and initialize:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Configure Servers
Once infrastructure is live, use Ansible to install dependencies:
```bash
cd ansible
# Update inventory.ini with EKS node IPs/Bastion
ansible-playbook -i inventory.ini site.yml
```

## 🛠️ Tech Stack
- **Provider**: AWS
- **IaC**: Terraform
- **Config Management**: Ansible
- **Orchestration**: Kubernetes (EKS)
- **Database**: PostgreSQL 16.1 + PostGIS
- **Data Engineering**: S3 Data Lake