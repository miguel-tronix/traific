# Kubernetes Deployment Guide

## Prerequisites

- Terraform >= 1.5 deployed (VPC, EKS, RDS, S3)
- kubectl configured (via `eks-setup.yml` or `aws eks update-kubeconfig`)
- Helm 3.x installed
- AWS credentials with permissions for EKS and IAM

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        EKS Cluster                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  MQTT Broker │  │    Redis     │  │   FastAPI REST   │  │
│  │  (EMQX x3)   │  │  (Stateful)  │  │     API (x2)     │  │
│  │  Spot Nodes  │  │ On-Demand    │  │   Spot Nodes     │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                   │            │
│  ┌──────▼─────────────────▼───────────────────▼────────┐  │
│  │           Stream Processor (x3)                      │  │
│  │              Spot Nodes                              │  │
│  └──────┬────────────────┬──────────────────────────────┘  │
│         │                │                                 │
│         ▼                ▼                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    RDS      │  │     S3      │  │  Analytics  │        │
│  │  PostgreSQL │  │  Data Lake  │  │  Celery (x2)│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
         │                                           │
    IoT Sensors ─────── MQTT ──────────────────────────┘
```

## Node Allocation

| Node Group | Instance Type | Capacity Type | Workloads |
|------------|--------------|---------------|-----------|
| `stateless` | t3.medium, t3a.medium | **Spot** | API, Stream Processor, Analytics workers |
| `redis` | t3.medium | **On-Demand** | Redis (data persistence) |

## Quick Start

### 1. Run Terraform

```bash
cd terraform
terraform init
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

### 2. Setup kubectl and Helm

```bash
cd ../ansible
ansible-playbook -i inventory.ini eks-setup.yml
```

### 3. Deploy Applications

```bash
ansible-playbook -i inventory.ini k8s-deploy.yml
```

Or manually with kubectl:

```bash
kubectl apply -k kubernetes/
kubectl apply -k kubernetes/mqtt/
kubectl apply -k kubernetes/redis/
kubectl apply -k kubernetes/api/
kubectl apply -k kubernetes/analytics/
```

### 4. Verify Deployment

```bash
# Check all pods
kubectl get pods -A

# Check EMQX
kubectl get pods -n traific-mqtt

# Check Redis
kubectl get pods -n traific-redis

# Check API
kubectl get pods -n traific-apps

# Get ALB endpoint
kubectl get ingress -A
```

## Per-Component Deployment

### MQTT Broker (EMQX)

EMQX provides MQTT 5.0 support, a web dashboard, and built-in clustering.

```bash
kubectl apply -f kubernetes/mqtt/
kubectl get svc -n traific-mqtt
# Access dashboard at: http://<emqx-lb>:18083
```

### Redis (Celery Broker + API Cache)

```bash
kubectl apply -f kubernetes/redis/
kubectl exec -it -n traific-redis redis-0 -- redis-cli ping
# Expected: PONG
```

### Stream Processor

Consumes MQTT messages, writes normalized data to RDS, and archives raw data to S3.

```bash
kubectl apply -f kubernetes/stream-processor/
kubectl logs -n traific-apps -l app=stream-processor --tail=50
```

### FastAPI REST API

```bash
kubectl apply -f kubernetes/api/
kubectl logs -n traific-apps -l app=traific-api --tail=50
```

### Analytics Workers

Celery workers process background aggregation jobs. Celery Beat schedules them.

```bash
kubectl apply -f kubernetes/analytics/
kubectl logs -n traific-apps -l app=analytics-worker --tail=50
```

## Configuration

### Environment Variables (ConfigMaps)

| ConfigMap | Key Variables |
|-----------|--------------|
| `stream-processor-config` | `MQTT_BROKER_URL`, `DB_HOST`, `BATCH_SIZE`, `S3_BUCKET` |
| `api-config` | `DB_HOST`, `REDIS_URL`, `CACHE_TTL_SECONDS` |
| `analytics-config` | `REDIS_URL`, `AGGREGATION_INTERVAL_MINUTES` |

### Secrets

All secrets are stored in Kubernetes Secrets. In production, use AWS Secrets Manager with the CSI driver:

```bash
# Install AWS Secrets CSI driver
helm install secrets-store-csi-driver aws/secrets-manager \
  --namespace kube-system
```

## Scaling

### HPA (Horizontal Pod Autoscaler)

- **API**: Scale 2→20 replicas, trigger at 70% CPU
- **Stream Processor**: Scale 3→10 replicas, trigger at 60% CPU/70% memory
- **Analytics**: Scale 2→8 replicas, trigger at 75% CPU

### Spot Node Scaling

The `stateless` node group scales 2→8 nodes automatically via EKS cluster autoscaler.

## Monitoring

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090 &
# Open: http://localhost:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000 &
# Open: http://localhost:3000 (admin/CHANGE_ME)

# EMQX Dashboard
kubectl port-forward -n traific-mqtt svc/emqx 18083:18083 &
# Open: http://localhost:18083 (admin/changeme)

# Redis
kubectl exec -it -n traific-redis redis-0 -- redis-cli info
```

## Upgrading

```bash
# Rolling update (zero downtime)
kubectl set image deployment/traific-api \
  traific-api=traific/api:v1.1 -n traific-apps

# Check rollout status
kubectl rollout status deployment/traific-api -n traific-apps

# Rollback if needed
kubectl rollout undo deployment/traific-api -n traific-apps
```

## Cleanup

```bash
# Delete all traific resources
kubectl delete -k kubernetes/

# Delete monitoring
kubectl delete -n monitoring --all

# Terraform destroy
cd terraform && terraform destroy
```

## Cost Optimization Tips

1. **Spot instances**: Stateless workloads run on Spot with 3+ replicas for HA
2. **Spot allocation strategy**: Use `mixed_instances_policy` in Terraform for better spot availability
3. **Cluster autoscaler**: Ensures nodes scale down when not needed
4. **HPA**: Automatically scales pods based on real demand
5. **gp3 storage**: 20% cheaper than gp2, higher IOPS on demand
6. **ARM64 (Graviton)**: Consider `m6g`/`t3a` instances for ~20% cost savings

## Recommended Production Additions

- Karpenter instead of managed node groups (60-70% cheaper than Spot)
- External Secrets Operator for AWS Secrets Manager integration
- ArgoCD for GitOps-based deployments
- Datadog or commercial APM for production monitoring
