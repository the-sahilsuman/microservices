#!/bin/bash

set -e

echo "=========================================="
echo " Starting Microservices Environment Setup "
echo "=========================================="

# ------------------------------------------
# Colors
# ------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


# ------------------------------------------
# Check Operating System
# ------------------------------------------

info "Checking operating system..."

if [ ! -f /etc/os-release ]; then
    error "Unable to detect operating system."
    exit 1
fi

. /etc/os-release

success "Operating System: $PRETTY_NAME"


# ------------------------------------------
# Update System Packages
# ------------------------------------------

info "Updating system packages..."

sudo apt-get update -y

success "System packages updated."


# ------------------------------------------
# Install Required Dependencies
# ------------------------------------------

info "Installing required dependencies..."

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https

success "Required dependencies installed."


# ------------------------------------------
# Install Docker
# ------------------------------------------

if command -v docker &> /dev/null
then
    success "Docker is already installed."
else
    info "Installing Docker..."

    curl -fsSL https://get.docker.com -o get-docker.sh

    sudo sh get-docker.sh

    rm get-docker.sh

    success "Docker installed successfully."
fi


# ------------------------------------------
# Start Docker
# ------------------------------------------

info "Starting Docker service..."

sudo systemctl enable docker
sudo systemctl start docker

success "Docker service is running."


# ------------------------------------------
# Add Current User to Docker Group
# ------------------------------------------

info "Adding current user to Docker group..."

sudo usermod -aG docker $USER

success "User added to Docker group."


# ------------------------------------------
# Install kubectl
# ------------------------------------------

if command -v kubectl &> /dev/null
then
    success "kubectl is already installed."
else
    info "Installing kubectl..."

    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    chmod +x kubectl

    sudo mv kubectl /usr/local/bin/

    success "kubectl installed successfully."
fi


# ------------------------------------------
# Install Kind
# ------------------------------------------

if command -v kind &> /dev/null
then
    success "Kind is already installed."
else
    info "Installing Kind..."

    ARCH=$(uname -m)

    if [ "$ARCH" = "x86_64" ]; then
        KIND_ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ]; then
        KIND_ARCH="arm64"
    else
        error "Unsupported architecture: $ARCH"
        exit 1
    fi

    curl -Lo ./kind \
    https://kind.sigs.k8s.io/dl/latest/kind-linux-${KIND_ARCH}

    chmod +x ./kind

    sudo mv ./kind /usr/local/bin/kind

    success "Kind installed successfully."
fi


# ------------------------------------------
# Verify Installations
# ------------------------------------------

echo ""
echo "=========================================="
echo " Verifying Installations "
echo "=========================================="

docker --version
kubectl version --client
kind version


# ------------------------------------------
# Final Message
# ------------------------------------------

echo ""
echo "=========================================="
echo " INSTALLATION COMPLETED SUCCESSFULLY "
echo "=========================================="

echo ""
echo "IMPORTANT:"
echo "Please logout and login again before running Docker"
echo "without sudo."
echo ""

echo "Next step:"
echo "./config.sh"
