# Architecture Overview

This document outlines the proposed architecture for the Geospatial Traffic Management Platform.
It acts as a textual representation of the system to be verified against `overall_traific_aws_architecture.png`.

## High-Level Architecture

The platform is designed to be a scalable, reproducible AWS environment for ingesting, processing, and serving geospatial traffic data.

### Core Components

1.  **VPC (Virtual Private Cloud)**
    - Secure network isolation with Public and Private subnets across multiple Availability Zones.
    - [Internet Gateway](terraform/vpc.tf) for public access (ALB).
    - [NAT Gateway](terraform/vpc.tf) (one instance) for private subnets to access the internet.

2.  **Compute Layer**
    - **EKS (Elastic Kubernetes Service)**: Version 1.29 cluster ([eks.tf](terraform/eks.tf)) orchestrating `t3.medium` worker nodes in private subnets.
    - **Node Groups**: Managed node groups with auto-scaling (1-3 nodes).

3.  **Data Storage**
    - **RDS (Relational Database Service)**: PostgreSQL 16.1 instance ([rds.tf](terraform/rds.tf)) using `db.t3.medium` and `gp3` storage.
    - **PostGIS**: Provisioned within RDS for geospatial processing.
    - **S3 Data Lake**: Versioned and encrypted bucket ([s3.tf](terraform/s3.tf)) for raw logs and historical data.

4.  **Traffic Management**
    - **Application Load Balancer (ALB)**: Integrated via EKS AWS Load Balancer Controller to handle ingress traffic.

## Architecture Diagram

```mermaid
graph TB
    %% Global Management Plane
    subgraph Global_Mgmt ["Global Management & Control Plane (Primary Region)"]
        direction TB
        CM[Cognito Multi-Tenant Pool]
        CF[AWS Control Tower]
        CD[CodePipeline / CodeDeploy]
        CO[Cost Explorer + Tags]
        CT[CloudTrail Logging]
        AD[AppConfig Flags]
        R53[Route 53 Geo-Routing]
    end

    %% Australia Region
    subgraph AU_Region ["AWS Region: ap-southeast-2 (Australia)"]
        subgraph Tenant_A ["Tenant A: City of Melbourne"]
            TA_ALB[ALB]
            TA_EKS[EKS Cluster: Namespace Melbourne]
            TA_RDS[(Aurora PostgreSQL)]
            TA_S3[S3: /tenant-a/]
            TA_APIG[API Gateway]
        end

        subgraph Tenant_B ["Tenant B: City of Geelong"]
            TB_ALB[ALB]
            TB_EKS[EKS Cluster: Namespace Geelong]
            TB_RDS[(Aurora PostgreSQL)]
            TB_APIG[API Gateway]
        end
    end

    %% Europe Region
    subgraph EU_Region ["AWS Region: eu-west-1 (Europe)"]
        subgraph Tenant_C ["Tenant C: City of London"]
            TC_APIG[API Gateway]
            TC_EKS[EKS Cluster]
            TC_RDS[(Aurora PostgreSQL)]
        end
    end

    %% Hybrid & Edge
    subgraph Edge ["On-Premise / Edge"]
        OP_Out[Outposts Rack]
        Sensors[IoT Sensors]
    end

    %% Observability
    subgraph Observability ["Central Observability Account"]
        CW[CloudWatch]
        XRay[X-Ray]
        Grafana[Managed Grafana]
    end

    %% Relationships
    Sensors -->|MQTT| AU_Region
    R53 -->|Traffic| TA_APIG
    R53 -->|Traffic| TB_APIG
    R53 -->|Traffic| TC_APIG

    TA_APIG -->|Auth| CM
    TA_EKS -->|Config| AD
    TA_EKS -->|Logs| CW
    TA_EKS -->|Data| TA_RDS
    
    OP_Out -->|Direct Connect| TA_EKS

    %% CI/CD Flows
    CD -.->|Deploy| TA_EKS
    CD -.->|Deploy| TB_EKS
    CD -.->|Deploy| TC_EKS

    %% Cost Attribution
    TA_RDS -.->|Tags| CO
    TA_EKS -.->|Tags| CO

    style Global_Mgmt fill:#f9f,stroke:#333,stroke-width:2px
    style AU_Region fill:#e1f5fe,stroke:#01579b
    style EU_Region fill:#e1f5fe,stroke:#01579b
    style Observability fill:#f1f8e9,stroke:#33691e
```

## Implementation Details & Verification
- **Alignment**: This documentation matches the current Terraform configuration in the `terraform/` directory.
- **Security**: RDS is isolated in private subnets with a security group allowing ingress only from the VPC CIDR (port 5432).
- **Public Access**: EKS endpoint is publicly accessible for administration, while worker nodes remain in private subnets.
- **Storage**: S3 bucket includes public access blocks and server-side encryption (AES256).
