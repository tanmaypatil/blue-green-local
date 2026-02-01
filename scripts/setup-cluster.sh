#!/bin/bash

# Setup script for kind cluster with ingress and monitoring
# Usage: ./scripts/setup-cluster.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CLUSTER_NAME="blue-green-cluster"

echo "=== Blue-Green Learning Cluster Setup ==="
echo ""

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster '${CLUSTER_NAME}' already exists."
    read -p "Delete and recreate? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing cluster..."
        kind delete cluster --name ${CLUSTER_NAME}
    else
        echo "Using existing cluster."
        kubectl cluster-info --context kind-${CLUSTER_NAME}
        exit 0
    fi
fi

# Step 1: Create kind cluster
echo ""
echo "Step 1/5: Creating kind cluster..."
kind create cluster --config "${PROJECT_DIR}/k8s/cluster/kind-config.yaml"

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Step 2: Create namespaces
echo ""
echo "Step 2/5: Creating namespaces..."
kubectl apply -f "${PROJECT_DIR}/k8s/cluster/namespaces.yaml"

# Step 3: Install nginx ingress controller
echo ""
echo "Step 3/5: Installing nginx ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# Step 4: Add Helm repositories
echo ""
echo "Step 4/5: Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Step 5: Install Prometheus and Grafana
echo ""
echo "Step 5/5: Installing Prometheus and Grafana..."

# Install Prometheus
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set server.persistentVolume.enabled=false \
  --set server.service.type=ClusterIP

# Install Grafana
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set adminPassword=admin \
  --set service.type=ClusterIP \
  --set "datasources.datasources\\.yaml.apiVersion=1" \
  --set "datasources.datasources\\.yaml.datasources[0].name=Prometheus" \
  --set "datasources.datasources\\.yaml.datasources[0].type=prometheus" \
  --set "datasources.datasources\\.yaml.datasources[0].url=http://prometheus-server.monitoring.svc.cluster.local" \
  --set "datasources.datasources\\.yaml.datasources[0].access=proxy" \
  --set "datasources.datasources\\.yaml.datasources[0].isDefault=true"

echo ""
echo "Waiting for monitoring stack to be ready..."
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=prometheus \
  --timeout=180s || true

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=180s || true

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Cluster: ${CLUSTER_NAME}"
echo ""
echo "Namespaces:"
kubectl get namespaces | grep -E "NAME|app|monitoring|ingress"
echo ""
echo "Access:"
echo "  - Application (after deployment): http://localhost"
echo "  - Grafana: kubectl port-forward -n monitoring svc/grafana 3000:80"
echo "            then open http://localhost:3000 (admin/admin)"
echo "  - Prometheus: kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo "                then open http://localhost:9090"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -A                    # All pods"
echo "  kubectl get pods -n app                # App namespace"
echo "  kubectl get pods -n monitoring         # Monitoring namespace"
echo "  k9s                                    # Terminal UI"
