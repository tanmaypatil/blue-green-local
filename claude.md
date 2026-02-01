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
├── docs/                        # Documentation
│   └── 00-prerequisites.md      # Installation guide
├── scripts/                     # Utility scripts
│   └── verify-prerequisites.sh  # Verify tool installations
├── k8s/                         # Kubernetes manifests (to be created)
├── services/                    # Application services (to be created)
│   ├── backend/
│   ├── jwt-service/
│   └── frontend/
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



