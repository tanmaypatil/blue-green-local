# Use local kubernetes deployment for learning blue-green

## Objective
Learn blue-green deployment using local kubernetes deployment.
Principle objective is for educational purpose.

## Tools
Tool to be used kind for k8s cluster deployment.

## Prerequisites

### Required Tools
| Tool | Purpose | Minimum Version |
|------|---------|-----------------|
| Docker | Container runtime | 20.10+ |
| kubectl | Kubernetes CLI | 1.28+ |
| kind | Local Kubernetes clusters | 0.20+ |
| helm | Kubernetes package manager | 3.12+ |

### Optional Tools
| Tool | Purpose |
|------|---------|
| k9s | Terminal-based Kubernetes UI |
| kubectx/kubens | Fast context/namespace switching |
| jq | JSON processing |

### Quick Install (macOS)
```bash
brew install kind helm        # Required
brew install k9s kubectx jq   # Optional
```

See `docs/00-prerequisites.md` for detailed installation instructions.

## Project Structure
```
blue-green-local/
├── CLAUDE.md                    # Project instructions and decisions
├── docs/
│   ├── 00-prerequisites.md      # Installation guide
│   ├── 01-cluster-setup.md      # Cluster setup guide
│   └── 02-progress.md           # Current progress and status
├── scripts/
│   ├── verify-prerequisites.sh  # Verify tool installations
│   ├── setup-cluster.sh         # Create cluster + monitoring
│   └── teardown-cluster.sh      # Delete cluster
├── k8s/
│   ├── cluster/
│   │   ├── kind-config.yaml     # Kind cluster configuration
│   │   └── namespaces.yaml      # Namespace definitions
│   ├── backend/
│   │   ├── deployment.yaml      # Backend deployment
│   │   └── service.yaml         # Backend service
│   └── ingress/
│       └── ingress.yaml         # Ingress routing rules
├── services/
│   ├── backend/                 # ✅ Complete
│   ├── jwt-service/             # ⏳ Pending
│   └── frontend/                # ⏳ Pending
└── helm/                        # Helm charts (to be created)
```

## Application
Application used will be simple application.
Consisting of:
 * Backend application - Python
   - Endpoint: `/calculate` with input `amount`
   - Response: double the input amount
 * Database - **PostgreSQL**
 * IDP - **Basic JWT service** (lightweight custom implementation)
 * Load balancer - nginx ingress controller
 * Frontend - Pure HTML with login screen + compute screen
 * Semantic versioning applied
 * Deployed in local k8s cluster using kind

## Foundational Practices (Built-in from Day 1)

### Dockerfiles
 * Multi-stage builds for all services
 * Optimized layer caching
 * Non-root user execution
 * Minimal base images (python:slim, nginx:alpine)

### Health Checks
 * **Liveness probes**: Detect stuck/deadlocked processes
 * **Readiness probes**: Service ready to accept traffic
 * **Startup probes**: For slow-starting containers
 * Endpoints: `/health/live`, `/health/ready` on each service

### Metrics & Observability
 * **Prometheus**: Metrics collection
 * **Grafana**: Dashboards and visualization
 * Application metrics exposed via `/metrics` endpoint
 * Key metrics:
   - Request latency (p50, p95, p99)
   - Request rate and error rate
   - Active connections
   - Blue/green deployment status

## Flow of the application
 * User is created via JWT service
 * User login through login screen, validated against JWT service
 * On success, open compute screen, click compute to call `/calculate` API

## Blue-green
  * Deploy new version of the application in blue-green fashion

  ### New application version (v2)
    * Modify `/calculate` endpoint with optional `discount` argument
    * Formula: `(amount * 2) - discount`

  ### Implementation Phases

  **Phase 1**: Ingress-based traffic splitting
    * Use nginx ingress annotations for traffic routing
    * Manual switching between blue/green deployments

  **Phase 2**: Argo Rollouts integration
    * Automated canary/blue-green with Argo Rollouts
    * Progressive delivery with analysis

  ### Testing Strategy
    * **Live traffic testing** - Load testing against blue version
    * **Manual tests** - Sanity checks before cutover
    * Status/monitoring page for deployment visibility

## Decisions Log
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Database | PostgreSQL | Realistic k8s patterns, good for learning |
| IDP | Basic JWT service | Lightweight, focuses learning on blue-green not auth complexity |
| Blue-green mechanism | Ingress-based (Phase 1), Argo Rollouts (Phase 2) | Progressive complexity |
| Starting point | From scratch | Full learning experience |
| Testing | Live traffic + load testing | Realistic validation with some manual checks |
| Dockerfiles | Multi-stage, optimized | Production-ready from day 1, not an afterthought |
| Health checks | Liveness + Readiness + Startup probes | Essential for k8s orchestration and blue-green |
| Metrics | Prometheus + Grafana | Observability built-in, critical for deployment visibility |

## Current Status

See `docs/02-progress.md` for detailed progress tracking.

### Quick Status

| Component | Status |
|-----------|--------|
| Kind Cluster | ✅ Running (1 control-plane + 2 workers) |
| Nginx Ingress | ✅ Deployed |
| Prometheus + Grafana | ✅ Deployed |
| Backend v1 | ✅ Deployed (2 replicas) |
| PostgreSQL | ⏳ Pending |
| JWT Service | ⏳ Pending |
| Frontend | ⏳ Pending |
| Blue-Green (Phase 1) | ⏳ Pending |
| Argo Rollouts (Phase 2) | ⏳ Pending |

### Access Points

| What | URL/Command |
|------|-------------|
| Backend API | `http://localhost/api/` |
| Calculate | `curl -X POST http://localhost/api/calculate -H "Content-Type: application/json" -d '{"amount":100}'` |
| Grafana | `kubectl port-forward -n monitoring svc/grafana 3000:80` → http://localhost:3000 |
| Prometheus | `kubectl port-forward -n monitoring svc/prometheus-server 9090:80` → http://localhost:9090 | 



