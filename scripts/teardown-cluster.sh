#!/bin/bash

# Teardown script for kind cluster
# Usage: ./scripts/teardown-cluster.sh

CLUSTER_NAME="blue-green-cluster"

echo "=== Tearing down cluster ==="

if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Deleting cluster '${CLUSTER_NAME}'..."
    kind delete cluster --name ${CLUSTER_NAME}
    echo "Cluster deleted."
else
    echo "Cluster '${CLUSTER_NAME}' does not exist."
fi
