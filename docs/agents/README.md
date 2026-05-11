# Traific MVP Agent Overview

This document provides an overview of the agents required to execute the Minimum Viable Product (MVP) phase of the Traific Geospatial Traffic Management Platform.

## MVP Scope Summary

The MVP focuses on delivering a single-tenant deployment in the Australia region (ap-southeast-2) to prove the core "Sensor to Insight" value chain.

**Timeline**: 6-8 Weeks

**Core Components**:
- VPC with public/private subnet isolation
- EKS cluster for container orchestration
- RDS PostgreSQL + PostGIS for geospatial data
- S3 Data Lake for raw data archival
- REST API for data access
- IoT ingestion pipeline for sensor data

---

## Agent Roles

### 1. Infrastructure Agent

**Focus**: AWS Resource Provisioning

- VPC and networking configuration
- EKS cluster deployment
- RDS PostgreSQL + PostGIS setup
- S3 Data Lake configuration
- Security groups and IAM roles

**Artifacts**: Terraform configurations

**Documentation**: [Infrastructure Agent](infrastructure_agent.md)

---

### 2. Platform/DevOps Agent

**Focus**: Platform Configuration and Deployment

- Ansible playbooks for server configuration
- CI/CD pipeline setup (GitHub Actions)
- Kubernetes manifests deployment
- Database migrations (Alembic)
- CloudWatch logging configuration

**Artifacts**: Ansible playbooks, CI/CD workflows, Kubernetes YAML

**Documentation**: [Platform/DevOps Agent](platform_devops_agent.md)

---

### 3. Data Pipeline Agent

**Focus**: IoT Ingestion and Stream Processing

- MQTT broker deployment for sensor data
- Stream processing service development
- Data normalization and validation
- S3 archival of raw data
- RDS persistence of normalized data

**Artifacts**: Stream processor code, MQTT configs

**Documentation**: [Data Pipeline Agent](data_pipeline_agent.md)

---

### 4. API Developer Agent

**Focus**: REST API Development

- FastAPI application development
- CRUD operations for TrafficObservation and Incident
- Geospatial querying (bounding box, radius search)
- API key authentication
- OpenAPI/Swagger documentation

**Artifacts**: FastAPI application, database models, API tests

**Documentation**: [API Developer Agent](api_developer_agent.md)

---

### 5. Analytics Agent

**Focus**: Data Aggregation and Metrics

- Background worker implementation (Celery)
- Scheduled aggregation jobs (hourly/daily)
- Metrics API for dashboard consumption
- Materialized views for performance
- Query optimization

**Artifacts**: Celery tasks, aggregation scripts, metrics APIs

**Documentation**: [Analytics Agent](analytics_agent.md)

---

## Sprint Mapping

| Sprint | Focus Area | Primary Agent |
|--------|------------|---------------|
| **Sprint 1** | Infrastructure & Data Foundation | Infrastructure Agent |
| **Sprint 2** | Platform Scaffolding & CI/CD | Platform/DevOps Agent |
| **Sprint 3** | IoT Ingestion & Stream Processing | Data Pipeline Agent |
| **Sprint 4** | Core API Development | API Developer Agent |
| **Sprint 5** | Analytics & Data Aggregation | Analytics Agent |
| **Sprint 6** | Security, Refinement & Documentation | API Developer Agent, Platform/DevOps Agent |
| **Sprint 7-8** | Integration Testing, Load Testing & UAT | All Agents |

---

## Data Flow Overview

```
┌─────────────┐     ┌────────────────┐     ┌─────────────────┐
│   Sensors   │────▶│ Data Pipeline  │────▶│    Analytics    │
│  (MQTT)     │     │    Agent        │     │     Agent       │
└─────────────┘     └────────┬────────┘     └─────────────────┘
                             │                        │
                    ┌────────┴────────┐               │
                    ▼                 ▼               ▼
              ┌──────────┐      ┌──────────┐   ┌──────────┐
              │   RDS    │      │    S3    │   │  Redis   │
              │ +PostGIS │      │Data Lake │   │  Cache   │
              └──────────┘      └──────────┘   └──────────┘
                    │                        │
                    └────────┬───────────────┘
                             ▼
                    ┌──────────────────┐
                    │  API Developer  │
                    │     Agent       │
                    └──────────────────┘
```

---

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.0
- Python 3.11+
- Docker and Kubernetes (kubectl)
- PostgreSQL + PostGIS for local development
- Redis for caching and task queue

---

## Getting Started

1. **Infrastructure Agent** deploys the AWS foundation using Terraform
2. **Platform/DevOps Agent** configures servers and sets up CI/CD
3. **Data Pipeline Agent** builds the ingestion and processing layer
4. **API Developer Agent** creates the REST API surface
5. **Analytics Agent** implements background jobs and metrics

Each agent operates somewhat independently but coordinates through:
- Shared database schema (PostgreSQL)
- API contracts
- Event-driven data flow
- Kubernetes namespace separation
