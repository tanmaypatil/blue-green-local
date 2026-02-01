# Project Progress

Last updated: 2026-02-01

## Current Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Kind Cluster                                    │
│                         (blue-green-cluster)                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Control Plane Node                            │   │
│  │                                                                  │   │
│  │   ┌────────────────────────────────────┐                        │   │
│  │   │  Nginx Ingress Controller          │ ◄── localhost:80       │   │
│  │   │  Routes /api/* → backend service   │                        │   │
│  │   └────────────────────────────────────┘                        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────┐         ┌──────────────────────┐             │
│  │      Worker 1        │         │      Worker 2        │             │
│  │                      │         │                      │             │
│  │  ┌────────────────┐  │         │  ┌────────────────┐  │             │
│  │  │ backend pod    │  │         │  │ backend pod    │  │             │
│  │  │ v1.0.0         │  │         │  │ v1.0.0         │  │             │
│  │  │                │  │         │  │                │  │             │
│  │  │ /calculate     │  │         │  │ /calculate     │  │             │
│  │  │ /health/live   │  │         │  │ /health/live   │  │             │
│  │  │ /health/ready  │  │         │  │ /health/ready  │  │             │
│  │  │ /metrics       │  │         │  │ /metrics       │  │             │
│  │  └────────────────┘  │         │  └────────────────┘  │             │
│  └──────────────────────┘         └──────────────────────┘             │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Monitoring Namespace                           │  │
│  │                                                                   │  │
│  │   Prometheus (metrics collection)                                 │  │
│  │   Grafana (dashboards)                                            │  │
│  │   Node Exporters (1 per node)                                     │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components Status

### Infrastructure

| Component | Status | Namespace | Notes |
|-----------|--------|-----------|-------|
| Kind Cluster | ✅ Done | - | 1 control-plane + 2 workers |
| Nginx Ingress | ✅ Done | ingress-nginx | Routes localhost:80 → cluster |
| Prometheus | ✅ Done | monitoring | Metrics collection |
| Grafana | ✅ Done | monitoring | Dashboards (admin/admin) |
| Node Exporters | ✅ Done | monitoring | 1 per node |

### Application

| Component | Status | Namespace | Version | Notes |
|-----------|--------|-----------|---------|-------|
| Backend | ✅ Done | app | v1.0.0 | 2 replicas |
| PostgreSQL | ⏳ Pending | app | - | Database |
| JWT Service | ⏳ Pending | app | - | Authentication |
| Frontend | ⏳ Pending | app | - | HTML UI |

### Blue-Green

| Component | Status | Notes |
|-----------|--------|-------|
| Backend v2 | ⏳ Pending | Add discount parameter |
| Blue deployment | ⏳ Pending | Deploy v2 alongside v1 |
| Traffic switching | ⏳ Pending | Ingress-based |
| Load testing | ⏳ Pending | Verify during switch |
| Argo Rollouts | ⏳ Phase 2 | Automated progressive delivery |

## Files Structure

```
blue-green-local/
├── CLAUDE.md                           # Project instructions
├── docs/
│   ├── 00-prerequisites.md             # Installation guide
│   ├── 01-cluster-setup.md             # Cluster setup guide
│   └── 02-progress.md                  # This file
├── scripts/
│   ├── verify-prerequisites.sh         # Verify tools installed
│   ├── setup-cluster.sh                # Create cluster + monitoring
│   └── teardown-cluster.sh             # Delete cluster
├── k8s/
│   ├── cluster/
│   │   ├── kind-config.yaml            # Kind cluster config
│   │   └── namespaces.yaml             # app + monitoring namespaces
│   ├── backend/
│   │   ├── deployment.yaml             # Backend deployment (2 replicas)
│   │   └── service.yaml                # Backend service
│   └── ingress/
│       └── ingress.yaml                # Routing rules (/api/* → backend)
└── services/
    └── backend/
        ├── app/
        │   ├── __init__.py             # Version: 1.0.0
        │   ├── main.py                 # FastAPI app
        │   ├── health.py               # Health endpoints
        │   └── metrics.py              # Prometheus metrics
        ├── Dockerfile                  # Multi-stage build
        ├── .dockerignore
        └── requirements.txt
```

## Access Points

### API Endpoints

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/api/` | GET | Service info | `curl http://localhost/api/` |
| `/api/calculate` | POST | Calculate amount × 2 | `curl -X POST http://localhost/api/calculate -H "Content-Type: application/json" -d '{"amount":100}'` |
| `/api/health/live` | GET | Liveness probe | `curl http://localhost/api/health/live` |
| `/api/health/ready` | GET | Readiness probe | `curl http://localhost/api/health/ready` |
| `/api/metrics` | GET | Prometheus metrics | `curl http://localhost/api/metrics` |

### Monitoring

| Service | Access Command | URL | Credentials |
|---------|---------------|-----|-------------|
| Grafana | `kubectl port-forward -n monitoring svc/grafana 3000:80` | http://localhost:3000 | admin / admin |
| Prometheus | `kubectl port-forward -n monitoring svc/prometheus-server 9090:80` | http://localhost:9090 | - |

### Useful Commands

```bash
# Check all pods
kubectl get pods -A

# Check app namespace
kubectl get pods -n app

# Check logs
kubectl logs -n app -l app=backend

# Watch pods
kubectl get pods -n app -w

# Terminal UI
k9s
```

## Pending Work

### Phase 1: Complete Application Stack

1. **PostgreSQL**
   - Deploy PostgreSQL with PersistentVolumeClaim
   - Create database schema
   - Connect backend to database

2. **JWT Service**
   - Simple Python service for authentication
   - Endpoints: `/register`, `/login`, `/verify`
   - Issue and validate JWT tokens

3. **Frontend**
   - HTML + JavaScript
   - Login screen
   - Compute screen (calls /calculate)

4. **Verify Metrics**
   - Confirm Prometheus scrapes backend
   - Create Grafana dashboard

### Phase 2: Blue-Green Deployment

1. **Backend v2**
   - Add optional `discount` parameter
   - Formula: `(amount × 2) - discount`

2. **Deploy Blue (v2)**
   - Create separate deployment
   - Both versions running simultaneously

3. **Traffic Switching**
   - Update ingress to route to v2
   - Rollback capability

4. **Load Testing**
   - Test during traffic switch
   - Verify zero downtime

### Phase 3: Argo Rollouts

1. Install Argo Rollouts
2. Convert deployment to Rollout
3. Automated canary/blue-green
4. Analysis and auto-promotion

## Lessons Learned

### Ingress Controller Placement
- **Issue**: Nginx ingress controller was scheduled on worker node, but port mapping only exists on control-plane
- **Fix**: Added `nodeSelector: ingress-ready=true` to ensure it runs on control-plane
- **Lesson**: hostPort binds to the node's port, not the cluster's. Pod must run on the correct node.

### Key Concepts Covered
- Kind cluster architecture (control-plane vs workers)
- Namespaces for isolation
- Services vs Ingress
- Ingress Controller pattern (watches API, generates nginx.conf)
- Path rewriting in Ingress
- Health probes (liveness, readiness, startup)
- Multi-stage Docker builds
- Loading images into Kind cluster
