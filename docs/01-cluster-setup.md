# Cluster Setup

This document covers the setup of the local Kubernetes cluster using kind.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kind Cluster (Docker)                        │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Control Plane  │  │    Worker 1     │  │    Worker 2     │ │
│  │                 │  │                 │  │                 │ │
│  │  - API Server   │  │  - App Pods     │  │  - App Pods     │ │
│  │  - Scheduler    │  │  - DB Pods      │  │  - Monitoring   │ │
│  │  - Ingress      │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Nginx Ingress Controller                    │   │
│  │         (Routes traffic to services)                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
└────────────────────────────│────────────────────────────────────┘
                             │
                    Port 80/443 mapped
                             │
                             ▼
                      localhost:80
                      localhost:443
```

## Components

### 1. Kind Cluster
- 1 control plane node (ingress-ready)
- 2 worker nodes
- Port mappings: 80, 443, 30000, 30001

### 2. Namespaces
| Namespace | Purpose |
|-----------|---------|
| `app` | Application workloads (backend, frontend, JWT service, PostgreSQL) |
| `monitoring` | Prometheus and Grafana |
| `ingress-nginx` | Ingress controller (created automatically) |

### 3. Nginx Ingress Controller
- Routes external traffic to services
- Enables path-based and host-based routing
- Critical for blue-green traffic switching

### 4. Monitoring Stack
- **Prometheus**: Metrics collection and storage
- **Grafana**: Dashboards and visualization
- Pre-configured datasource connection

## Setup

### Quick Start

```bash
./scripts/setup-cluster.sh
```

### Manual Setup

#### Step 1: Create Cluster
```bash
kind create cluster --config k8s/cluster/kind-config.yaml
```

#### Step 2: Create Namespaces
```bash
kubectl apply -f k8s/cluster/namespaces.yaml
```

#### Step 3: Install Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
```

#### Step 4: Install Prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set server.persistentVolume.enabled=false
```

#### Step 5: Install Grafana
```bash
helm repo add grafana https://grafana.github.io/helm-charts

helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set adminPassword=admin
```

## Accessing Services

### Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000
# Login: admin / admin
```

### Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Open http://localhost:9090
```

### Application (after deployment)
```bash
# Direct via ingress
curl http://localhost/api/health

# Or port-forward specific service
kubectl port-forward -n app svc/backend 8080:80
```

## Teardown

```bash
./scripts/teardown-cluster.sh

# Or manually
kind delete cluster --name blue-green-cluster
```

## Troubleshooting

### Cluster won't start
```bash
# Check Docker resources
docker system info | grep -E "CPUs|Memory"

# Clean up Docker
docker system prune -f
```

### Ingress not working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Port 80 already in use
```bash
# Find process using port 80
sudo lsof -i :80

# Stop the process or modify kind-config.yaml to use different ports
```

### Prometheus/Grafana pods not starting
```bash
# Check pod status
kubectl get pods -n monitoring

# Check events
kubectl describe pod -n monitoring <pod-name>

# Check logs
kubectl logs -n monitoring <pod-name>
```

## Useful Commands

```bash
# Cluster info
kubectl cluster-info --context kind-blue-green-cluster

# All pods across namespaces
kubectl get pods -A

# Watch pods in app namespace
kubectl get pods -n app -w

# Node status
kubectl get nodes -o wide

# Resource usage (requires metrics-server)
kubectl top nodes
kubectl top pods -A
```

## Next Steps

Once the cluster is running:
1. Proceed to deploy PostgreSQL
2. Deploy JWT authentication service
3. Deploy backend application
4. Deploy frontend
5. Implement blue-green switching
