# Project Estimation: Traific Platform MVP

This document outlines the detailed estimation for the initial **Minimum Viable Product (MVP)** of the Traific platform.
The goal is to prove the core "Sensor to Insight" value chain for a single tenant in the Australia region.

## 🎯 MVP Delivery Plan (6 - 8 Weeks)

To ensure confidence and clear tracking, the MVP delivery is broken down into weekly sprints.

### Sprint 1: Infrastructure & Data Foundation

* Provision foundational AWS VPC and networking (Terraform).
* Deploy single-tenant EKS Cluster in `ap-southeast-2`.
* Deploy RDS PostgreSQL + PostGIS instance.
* Setup S3 Data Lake buckets.

### Sprint 2: Platform Scaffolding & CI/CD

* Configure EKS load balancing (ALB Controller) and ingress.
* Bootstrap FastAPI application repository with basic CI testing.
* Setup database schema migrations (Alembic) for core tables (`RoadSegment`, `Sensor`).
* Configure basic CloudWatch logging.

### Sprint 3: IoT Ingestion & Stream Processing

* Deploy basic MQTT broker for sensor data ingestion.
* Implement stream processing service to normalize raw sensor data.
* Establish pipeline to archive raw data to S3 and write normalized data to RDS.

### Sprint 4: Core API Development

* Implement CRUD REST APIs for `TrafficObservation` and `Incident` entities.
* Develop basic geospatial querying capabilities (e.g., finding incidents within a bounding box).
* Add unit and integration tests for API endpoints.

### Sprint 5: Analytics & Data Aggregation

* Develop background workers/cron jobs for daily traffic volume aggregation.
* Implement APIs to serve aggregated metrics to frontend dashboards.
* Optimize slow PostgreSQL spatial queries.

### Sprint 6: Security, Refinement & Documentation

* Implement basic API key authentication for external access.
* Refine API error handling and input validation.
* Generate API documentation (Swagger/OpenAPI).
* Write operational runbooks for basic troubleshooting.

### Sprint 7-8: Integration Testing, Load Testing & UAT

* Perform end-to-end integration testing (Sensor simulator -> Ingestion -> Database -> API).
* Conduct load testing to ensure stability under expected MVP traffic.
* Bug fixing and performance tuning based on test results.
* User Acceptance Testing (UAT) with pilot stakeholders.

## 💰 MVP Effort Summary

| Sprint | Focus Area | Status |
| :--- | :--- | :--- |
| **Sprint 1** | Infra & Data Foundation | Pending |
| **Sprint 2** | Platform Scaffolding | Pending |
| **Sprint 3** | IoT Ingestion | Pending |
| **Sprint 4** | Core API Development | Pending |
| **Sprint 5** | Analytics & Aggregation | Pending |
| **Sprint 6** | Security & Refinement | Pending |
| **Sprint 7-8** | Testing, Load & UAT | Pending |
| **Total** | **MVP Delivery** | **6 - 8 Weeks** |

---

## 🌍 Future Roadmap: Global Multi-Tenant Architecture (Post-MVP)

*Note: The following represents the long-term vision and will be estimated in detail only after successful MVP validation. Historically estimated at an additional 20-24 weeks.*

### Phase 1: Global Management Plane & Enhanced Observability

* AWS Control Tower for multi-account structure.
* Cognito for robust multi-tenant authentication.
* Centralized X-Ray tracing and Grafana dashboards.

### Phase 2: Multi-Tenancy & Isolation

* Automated tenant onboarding via CodePipeline.
* Strict namespace, database, and S3 path isolation per tenant.
* Tenant-aware routing and rate limiting.

### Phase 3: Global Expansion (EU Region)

* Replicate infrastructure to `eu-west-1`.
* Implement Route53 Geolocation routing.
* Cross-region data replication for disaster recovery.

### Phase 4: Edge Processing (AWS IoT Greengrass)

* Deploy IoT Greengrass Core on physical edge devices at sensor sites.
* Push local ML inference and data filtering to the edge to reduce data transfer costs.

## Key Risks & Dependencies

### Technical Risks

1. **Edge Device Availability**: IoT Greengrass edge devices (Raspberry Pi / industrial PCs) procurement and setup.
2. **Complexity**: Managing state across regions (Global Control Plane) is non-trivial.
3. **Data Consistency**: Cross-region eventual consistency challenges for real-time traffic data.
4. **Sensor Integration**: IoT device compatibility and MQTT protocol variations.

### Cost Risks

1. **Multi-Region Costs**: Active-active architectures double compute/database costs.
2. **Edge Hardware**: Low-cost edge devices (~$500-$5K per site) but scales with number of locations.
3. **Data Transfer**: Cross-region data egress charges and IoT Core message pricing.

### Organizational Dependencies

1. **AWS Account Approval**: Control Tower requires AWS Organization master account access.
2. **Stakeholder Availability**: UAT requires Prof. Majid's team engagement (Phase 5).
3. **Security Review**: Network architecture approval from University InfoSec team.

## Assumptions

- Terraform and Ansible expertise available on team.
* AWS account limits pre-approved (e.g., EKS cluster limits, Elastic IP quotas).
* Sensor data schemas are well-defined and stable.
* No major architectural pivots required post-MVP validation.
