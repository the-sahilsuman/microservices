#!/bin/bash

set -e

# ==========================================
# Microservices Kubernetes Configuration
# ==========================================

NAMESPACE="microservices"
CLUSTER_NAME="microservices"
K8S_DIR="k8s"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


echo ""
echo "=============================================="
echo " Microservices Kubernetes Deployment"
echo "=============================================="
echo ""


# ==========================================
# Check Required Commands
# ==========================================

info "Checking required tools..."

for command in docker kubectl kind
do
    if ! command -v "$command" &> /dev/null
    then
        error "$command is not installed."
        error "Please run ./install.sh first."
        exit 1
    fi
done

success "Docker, kubectl and Kind are available."


# ==========================================
# Check Docker
# ==========================================

info "Checking Docker..."

if ! docker info &> /dev/null
then
    error "Docker is not running or current user does not have permission."
    echo ""
    echo "Try:"
    echo "sudo systemctl start docker"
    echo "newgrp docker"
    exit 1
fi

success "Docker is running."


# ==========================================
# Check Kubernetes Files
# ==========================================

info "Checking Kubernetes configuration files..."

REQUIRED_FILES=(
    "$K8S_DIR/cluster.yml"
    "$K8S_DIR/namespace.yml"
    "$K8S_DIR/configmap.yml"
    "$K8S_DIR/pv.yml"
    "$K8S_DIR/pvc.yml"
    "$K8S_DIR/deployment.yml"
    "$K8S_DIR/service.yml"
    "$K8S_DIR/networkpolicy.yml"
    "$K8S_DIR/ingress.yml"
)

for file in "${REQUIRED_FILES[@]}"
do
    if [ ! -f "$file" ]
    then
        error "Required file not found: $file"
        exit 1
    fi
done

success "All required Kubernetes files found."


# ==========================================
# Create Kind Cluster
# ==========================================

info "Checking Kind cluster..."

if kind get clusters | grep -q "^${CLUSTER_NAME}$"
then
    warning "Kind cluster '${CLUSTER_NAME}' already exists."
else
    info "Creating Kind cluster..."

    kind create cluster \
        --config "$K8S_DIR/cluster.yml"

    success "Kind cluster created successfully."
fi


# ==========================================
# Wait for Kubernetes
# ==========================================

info "Waiting for Kubernetes cluster..."

kubectl wait \
    --for=condition=Ready nodes \
    --all \
    --timeout=180s

success "Kubernetes nodes are ready."


# ==========================================
# Display Cluster Information
# ==========================================

echo ""

info "Cluster information:"

kubectl cluster-info

echo ""

kubectl get nodes

echo ""


# ==========================================
# Install Metrics Server
# ==========================================

info "Checking Metrics Server..."

if kubectl get deployment metrics-server \
    -n kube-system &> /dev/null
then
    success "Metrics Server already installed."
else

    info "Installing Metrics Server..."

    kubectl apply -f \
    https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

    success "Metrics Server installed."
fi


# ==========================================
# Configure Metrics Server for Kind
# ==========================================

info "Configuring Metrics Server..."

kubectl patch deployment metrics-server \
    -n kube-system \
    --type='json' \
    -p='[
        {
            "op":"add",
            "path":"/spec/template/spec/containers/0/args/-",
            "value":"--kubelet-insecure-tls"
        }
    ]' || true

success "Metrics Server configuration completed."


# ==========================================
# Install NGINX Ingress Controller
# ==========================================

info "Checking NGINX Ingress Controller..."

if kubectl get namespace ingress-nginx &> /dev/null
then
    success "NGINX Ingress Controller already exists."
else

    info "Installing NGINX Ingress Controller..."

    kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    success "NGINX Ingress Controller installed."
fi


# ==========================================
# Wait for Ingress Controller
# ==========================================

info "Waiting for NGINX Ingress Controller..."

kubectl wait \
    --namespace ingress-nginx \
    --for=condition=Ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=300s || warning "Ingress controller is still starting."

success "Ingress setup completed."


# ==========================================
# Apply Namespace
# ==========================================

info "Creating application namespace..."

kubectl apply -f "$K8S_DIR/namespace.yml"

success "Namespace configured."


# ==========================================
# Apply ConfigMap
# ==========================================

info "Applying ConfigMap..."

kubectl apply -f "$K8S_DIR/configmap.yml"

success "ConfigMap applied."


# ==========================================
# Apply Persistent Volume
# ==========================================

info "Creating Persistent Volume..."

kubectl apply -f "$K8S_DIR/pv.yml"

success "Persistent Volume applied."


# ==========================================
# Apply Persistent Volume Claim
# ==========================================

info "Creating Persistent Volume Claim..."

kubectl apply -f "$K8S_DIR/pvc.yml"

success "Persistent Volume Claim applied."


# ==========================================
# Deploy Applications
# ==========================================

info "Deploying microservices..."

kubectl apply -f "$K8S_DIR/deployment.yml"

success "Application deployments created."


# ==========================================
# Create Kubernetes Services
# ==========================================

info "Creating Kubernetes services..."

kubectl apply -f "$K8S_DIR/service.yml"

success "Services created."


# ==========================================
# Apply Network Policies
# ==========================================

info "Applying Network Policies..."

kubectl apply -f "$K8S_DIR/networkpolicy.yml"

success "Network Policies applied."


# ==========================================
# Apply Ingress
# ==========================================

info "Applying Ingress configuration..."

kubectl apply -f "$K8S_DIR/ingress.yml"

success "Ingress configuration applied."


# ==========================================
# Apply HPA
# ==========================================

if [ -f "$K8S_DIR/hpa.yml" ]
then

    info "Applying Horizontal Pod Autoscaler..."

    kubectl apply -f "$K8S_DIR/hpa.yml"

    success "HPA configuration applied."

else

    warning "hpa.yml not found. Skipping HPA."

fi


# ==========================================
# Apply VPA
# ==========================================

if [ -f "$K8S_DIR/vpa.yml" ]
then

    info "Checking VPA installation..."

    if kubectl api-resources | grep -q "verticalpodautoscalers"
    then

        info "Applying Vertical Pod Autoscaler..."

        kubectl apply -f "$K8S_DIR/vpa.yml"

        success "VPA configuration applied."

    else

        warning "VPA CRDs are not installed."
        warning "Skipping VPA deployment."

    fi

fi


# ==========================================
# Wait for Application Deployments
# ==========================================

info "Waiting for Node.js deployment..."

kubectl rollout status \
deployment/deployment-nodejs \
-n "$NAMESPACE" \
--timeout=300s


info "Waiting for Java deployment..."

kubectl rollout status \
deployment/deployment-java \
-n "$NAMESPACE" \
--timeout=300s


info "Waiting for Python deployment..."

kubectl rollout status \
deployment/deployment-python \
-n "$NAMESPACE" \
--timeout=300s


# ==========================================
# Final Verification
# ==========================================

echo ""

echo "=============================================="
echo " Kubernetes Deployment Status"
echo "=============================================="

echo ""

info "Nodes:"
kubectl get nodes

echo ""

info "Pods:"
kubectl get pods -n "$NAMESPACE" -o wide

echo ""

info "Services:"
kubectl get svc -n "$NAMESPACE"

echo ""

info "Persistent Volume Claims:"
kubectl get pvc -n "$NAMESPACE"

echo ""

info "Ingress:"
kubectl get ingress -n "$NAMESPACE"

echo ""

info "Horizontal Pod Autoscaler:"
kubectl get hpa -n "$NAMESPACE" 2>/dev/null || true

echo ""

info "Vertical Pod Autoscaler:"
kubectl get vpa -n "$NAMESPACE" 2>/dev/null || true

echo ""

echo "=============================================="
echo " DEPLOYMENT COMPLETED SUCCESSFULLY"
echo "=============================================="

echo ""

echo "Useful commands:"
echo ""

echo "kubectl get pods -n microservices"
echo "kubectl get svc -n microservices"
echo "kubectl get ingress -n microservices"
echo "kubectl get hpa -n microservices"
echo ""

echo "Application services are now deployed."
echo ""
