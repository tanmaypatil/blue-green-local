# Prerequisites

Complete installation guide for the blue-green deployment learning project.

## Required Tools

| Tool | Purpose | Minimum Version |
|------|---------|-----------------|
| Docker | Container runtime | 20.10+ |
| kubectl | Kubernetes CLI | 1.28+ |
| kind | Local Kubernetes clusters | 0.20+ |
| helm | Kubernetes package manager | 3.12+ |

## Optional (Recommended) Tools

| Tool | Purpose |
|------|---------|
| k9s | Terminal-based Kubernetes UI |
| kubectx/kubens | Fast context/namespace switching |
| jq | JSON processing in terminal |

---

## Installation Instructions (macOS)

### 1. Homebrew (Package Manager)

If you don't have Homebrew installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Docker Desktop

**Option A: Download directly**
- Download from: https://www.docker.com/products/docker-desktop/
- Install the `.dmg` file
- Start Docker Desktop from Applications

**Option B: Homebrew**
```bash
brew install --cask docker
```

After installation, start Docker Desktop and ensure it's running (whale icon in menu bar).

**Verify:**
```bash
docker --version
docker run hello-world
```

### 3. kubectl

```bash
brew install kubectl
```

**Verify:**
```bash
kubectl version --client
```

### 4. kind (Kubernetes IN Docker)

```bash
brew install kind
```

**Verify:**
```bash
kind version
```

### 5. helm

```bash
brew install helm
```

**Verify:**
```bash
helm version
```

### 6. Optional Tools

```bash
# k9s - Terminal UI for Kubernetes
brew install k9s

# kubectx + kubens - Context and namespace switching
brew install kubectx

# jq - JSON processor
brew install jq
```

---

## Installation Instructions (Linux - Ubuntu/Debian)

### 1. Docker

```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install prerequisites
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (logout required after)
sudo usermod -aG docker $USER
```

### 2. kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

### 3. kind

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### 4. helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 5. Optional Tools

```bash
# k9s
curl -sS https://webinstall.dev/k9s | bash

# kubectx + kubens
sudo apt-get install kubectx

# jq
sudo apt-get install jq
```

---

## Installation Instructions (Windows)

### Using winget (Windows Package Manager)

```powershell
# Docker Desktop
winget install Docker.DockerDesktop

# kubectl
winget install Kubernetes.kubectl

# kind
winget install Kubernetes.kind

# helm
winget install Helm.Helm
```

### Using Chocolatey

```powershell
choco install docker-desktop kubectl kind kubernetes-helm
```

---

## Verification Checklist

Run this script to verify all installations:

```bash
#!/bin/bash

echo "=== Prerequisites Verification ==="
echo ""

# Docker
echo -n "Docker: "
if command -v docker &> /dev/null; then
    docker --version | cut -d' ' -f3 | tr -d ','
    echo -n "  Docker daemon: "
    if docker info &> /dev/null; then
        echo "Running"
    else
        echo "NOT RUNNING - Start Docker Desktop"
    fi
else
    echo "NOT INSTALLED"
fi

# kubectl
echo -n "kubectl: "
if command -v kubectl &> /dev/null; then
    kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' 2>/dev/null || kubectl version --client 2>/dev/null | head -1
else
    echo "NOT INSTALLED"
fi

# kind
echo -n "kind: "
if command -v kind &> /dev/null; then
    kind version | cut -d' ' -f2
else
    echo "NOT INSTALLED"
fi

# helm
echo -n "helm: "
if command -v helm &> /dev/null; then
    helm version --short
else
    echo "NOT INSTALLED"
fi

echo ""
echo "=== Optional Tools ==="

# k9s
echo -n "k9s: "
if command -v k9s &> /dev/null; then
    k9s version --short 2>/dev/null || echo "installed"
else
    echo "not installed (optional)"
fi

# kubectx
echo -n "kubectx: "
if command -v kubectx &> /dev/null; then
    echo "installed"
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
echo "=== Verification Complete ==="
```

Save this as `verify-prerequisites.sh` and run:
```bash
chmod +x verify-prerequisites.sh
./verify-prerequisites.sh
```

---

## Docker Desktop Settings (Recommended)

After installing Docker Desktop, configure these settings for kind:

1. **Resources > Memory**: At least 4GB (8GB recommended)
2. **Resources > CPUs**: At least 2 (4 recommended)
3. **Resources > Disk**: At least 20GB

---

## Troubleshooting

### Docker daemon not running
```bash
# macOS: Start Docker Desktop from Applications
open -a Docker

# Linux: Start docker service
sudo systemctl start docker
```

### Permission denied on Docker socket (Linux)
```bash
sudo usermod -aG docker $USER
# Then logout and login again
```

### kind cluster creation fails
```bash
# Check Docker is running
docker ps

# Check available resources
docker system info | grep -E "CPUs|Memory"

# Clean up any existing clusters
kind delete clusters --all
```

### helm repo issues
```bash
# Update repos
helm repo update

# If repo not found, add it
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

---

## Quick Install (macOS - Copy/Paste)

```bash
# Install all required tools
brew install kubectl kind helm

# Install optional tools
brew install k9s kubectx jq

# Verify
kubectl version --client
kind version
helm version
```

---

## Next Steps

Once all prerequisites are installed and verified:
1. Proceed to `01-cluster-setup.md` for kind cluster creation
2. Install nginx ingress controller
3. Set up Prometheus and Grafana

