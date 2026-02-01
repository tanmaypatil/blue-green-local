#!/bin/bash

# Prerequisites verification script for blue-green deployment project

echo "=== Prerequisites Verification ==="
echo ""

REQUIRED_PASSED=0
REQUIRED_TOTAL=4

# Docker
echo -n "Docker: "
if command -v docker &> /dev/null; then
    docker --version | cut -d' ' -f3 | tr -d ','
    echo -n "  Docker daemon: "
    if docker info &> /dev/null; then
        echo "Running ✓"
        ((REQUIRED_PASSED++))
    else
        echo "NOT RUNNING - Start Docker Desktop ✗"
    fi
else
    echo "NOT INSTALLED ✗"
fi

# kubectl
echo -n "kubectl: "
if command -v kubectl &> /dev/null; then
    kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' 2>/dev/null || kubectl version --client 2>/dev/null | head -1
    ((REQUIRED_PASSED++))
else
    echo "NOT INSTALLED ✗"
fi

# kind
echo -n "kind: "
if command -v kind &> /dev/null; then
    kind version 2>/dev/null | head -1
    ((REQUIRED_PASSED++))
else
    echo "NOT INSTALLED ✗"
fi

# helm
echo -n "helm: "
if command -v helm &> /dev/null; then
    helm version --short 2>/dev/null
    ((REQUIRED_PASSED++))
else
    echo "NOT INSTALLED ✗"
fi

echo ""
echo "=== Optional Tools ==="

# k9s
echo -n "k9s: "
if command -v k9s &> /dev/null; then
    echo "installed ✓"
else
    echo "not installed (optional)"
fi

# kubectx
echo -n "kubectx: "
if command -v kubectx &> /dev/null; then
    echo "installed ✓"
else
    echo "not installed (optional)"
fi

# jq
echo -n "jq: "
if command -v jq &> /dev/null; then
    jq --version
else
    echo "not installed (optional)"
fi

echo ""
echo "=== Summary ==="
echo "Required tools: $REQUIRED_PASSED/$REQUIRED_TOTAL"

if [ $REQUIRED_PASSED -eq $REQUIRED_TOTAL ]; then
    echo ""
    echo "All required tools installed. Ready to proceed!"
    exit 0
else
    echo ""
    echo "Some required tools are missing. Please install them first."
    echo ""
    echo "Quick install (macOS):"
    echo "  brew install kind helm"
    exit 1
fi
