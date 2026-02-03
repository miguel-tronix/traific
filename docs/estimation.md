# Project Estimation: Traific Global Platform

This document outlines the phased estimation for the Traific platform, distinguishing between an initial **Minimum Viable Product (MVP)** to prove the core value and the **Full Global Build-out** required for the target multi-tenant architecture.

## 🎯 MVP: Proof of Concept (Single Tenant / AU Region)
**Goal:** Establish end-to-end data flow for a single tenant (e.g., City of Melbourne) in the Australia region. Prove the "Sensor to Insight" value chain without the complexity of global orchestration.

**Estimated Effort:** 6 - 8 Weeks

### Scope
1.  **Foundation (AU Region)**
    - Single VPC in `ap-southeast-2`.
    - EKS Cluster (Standard, not multi-tenant yet).
    - RDS PostgreSQL + PostGIS (Single instance).
2.  **Data Ingestion**
    - Basic IoT MQTT broker (Mosquitto/AWS IoT Core) -> Kinesis/Kafka -> EKS.
    - Stream processing service for sensor data normalization.
3.  **Application Foundation**
    - FastAPI application scaffolding with project structure.
    - PostGIS schema implementation per `data_model.md` (RoadSegment, Sensor, TrafficObservation, Incident).
    - CRUD REST APIs for core entities.
    - Unit test framework (pytest) setup.
4.  **Data Engineering**
    - S3 Data Lake bucket structure and lifecycle policies.
    - Raw sensor data archival pipeline.
    - Basic ETL for historical analytics.
5.  **Observability**
    - CloudWatch Logs integration for application logs.
    - Basic CloudWatch dashboards for API metrics.
    - **No** Global Control Tower, **No** Multi-Region, **No** Outposts.

| Workstream | Effort (Weeks) |
| :--- | :--- |
| **Infra Setup (Terraform)** | 1 - 2 |
| **Ingestion Pipeline** | 1 - 2 |
| **Application Development** | 2 - 2.5 |
| **Data Engineering** | 1 - 1.5 |
| **Total MVP** | **6 - 8 Weeks** |

---

## 🌍 Full Build-out: Global Multi-Tenant Architecture
**Goal:** Evolve the MVP into the managed, scalable, multi-region platform described in the architecture diagram.

**Estimated Effort:** 23 - 32 Weeks (Post-MVP)

### Phase 1: Global Management Plane & Enhanced Observability
**Effort: 5 - 7 Weeks**
- **AWS Control Tower**: Multi-account organization structure setup.
- **Identity**: Cognito User Pools for multi-tenant auth (Admin vs Tenant roles).
- **CI/CD Factory**: CodePipeline templates spawning per-tenant pipelines.
- **Observability Stack**:
    - Centralized CloudWatch Logs aggregation account.
    - AWS X-Ray distributed tracing integration.
    - Managed Grafana dashboards for cross-tenant metrics.
    - CloudTrail for audit logging.
- **Cost Management**: Cost Explorer setup with tenant-level tagging strategy.

### Phase 2: Multi-Tenancy & Isolation (AU Region)
**Effort: 5 - 6 Weeks**
- **Tenant Onboarding Automation**: 
    - IaC templates for provisioning "Tenant B" (Geelong).
    - Database schema isolation (separate schemas or RDS instances).
    - Kubernetes namespace creation with resource quotas.
    - DNS subdomain configuration (`tenant-b.traific.io`).
- **Resource Isolation**: 
    - EKS namespace-level network policies.
    - RDS IAM authentication per tenant.
    - S3 bucket prefixes with IAM path-based access.
- **Routing**: ALB listener rules with host-based routing.
- **Testing**: Load testing with multi-tenant simulation.

### Phase 3: Global Expansion (EU Region)
**Effort: 4 - 6 Weeks**
- **Region Bootstrapping**: Replicate AU infrastructure to `eu-west-1` via Terraform modules.
- **Global Routing**: Route53 Geolocation and latency-based routing policies.
- **Data Replication**: 
    - Cross-region S3 replication for compliance/backup.
    - RDS read replicas for disaster recovery (optional).
- **Latency Optimization**: CloudFront distribution for static assets (if applicable).
- **Compliance**: GDPR considerations for EU data residency.

### Phase 4: Edge Processing (AWS IoT Greengrass)
**Effort: 2 - 3 Weeks**
- **Edge Gateway Setup**: 
    - Deploy IoT Greengrass Core on edge devices (Raspberry Pi 4 / industrial PCs at sensor sites).
    - Lambda functions for local sensor data filtering and aggregation.
- **Local Processing**: 
    - Real-time data normalization at the edge.
    - ML inference for anomaly detection (reduce cloud data transfer).
    - Offline operation with automatic sync when connectivity restored.
- **Cloud Integration**: 
    - AWS IoT Core MQTT bridge configuration.
    - S3 archival of processed edge data.
    - CloudWatch metrics for edge device health monitoring.
- **Device Management**: 
    - Over-the-air (OTA) updates for edge software.
    - Fleet provisioning for multiple edge locations.

### Phase 5: Integration Testing & QA
**Effort: 3 - 4 Weeks**
- **Integration Testing**: End-to-end sensor-to-API flows across all regions.
- **Load Testing**: Simulating peak traffic loads (10K+ concurrent sensors).
- **Security Testing**: Penetration testing and IAM policy audits.
- **UAT**: User Acceptance Testing with Prof. Majid's team.
- **Documentation**: API documentation, runbooks, disaster recovery procedures.

## 💰 Total Effort Summary

| Phase | Scope | Estimate |
| :--- | :--- | :--- |
| **MVP** | Single Tenant / AU + App Foundation | **6 - 8 Weeks** |
| **Phase 1** | Global  Mgmt Plane + Observability | 5 - 7 Weeks |
| **Phase 2** | Multi-Tenancy + Isolation | 5 - 6 Weeks |
| **Phase 3** | Global Expansion (EU) | 4 - 6 Weeks |
| **Phase 4** | Edge (IoT Greengrass) | 2 - 3 Weeks |
| **Phase 5** | Integration Testing & QA | 3 - 4 Weeks |
| **Total Project** | **Full Global Vision** | **25 - 32 Weeks** |

## Key Risks & Dependencies

### Technical Risks
1.  **Edge Device Availability**: IoT Greengrass edge devices (Raspberry Pi / industrial PCs) procurement and setup.
2.  **Complexity**: Managing state across regions (Global Control Plane) is non-trivial.
3.  **Data Consistency**: Cross-region eventual consistency challenges for real-time traffic data.
4.  **Sensor Integration**: IoT device compatibility and MQTT protocol variations.

### Cost Risks
1.  **Multi-Region Costs**: Active-active architectures double compute/database costs.
2.  **Edge Hardware**: Low-cost edge devices (~$500-$5K per site) but scales with number of locations.
3.  **Data Transfer**: Cross-region data egress charges and IoT Core message pricing.

### Organizational Dependencies
1.  **AWS Account Approval**: Control Tower requires AWS Organization master account access.
2.  **Stakeholder Availability**: UAT requires Prof. Majid's team engagement (Phase 5).
3.  **Security Review**: Network architecture approval from University InfoSec team.

## Assumptions
- Terraform and Ansible expertise available on team.
- AWS account limits pre-approved (e.g., EKS cluster limits, Elastic IP quotas).
- Sensor data schemas are well-defined and stable.
- No major architectural pivots required post-MVP validation.
