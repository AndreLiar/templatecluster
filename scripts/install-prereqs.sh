#!/usr/bin/env bash
set -e

# Install prerequisites based on OS
echo "🔍 Detecting operating system..."

case "$OSTYPE" in
  darwin*)
    echo "✅ macOS detected - using Homebrew"
    if ! command -v brew &> /dev/null; then
      echo "❌ Homebrew not found. Please install it from https://brew.sh"
      exit 1
    fi
    echo "📦 Installing prerequisites..."
    brew install k3d kubectl terraform helm jq
    ;;
  linux-gnu*)
    echo "✅ Linux detected - using apt-get"
    if ! command -v apt-get &> /dev/null; then
      echo "⚠️  apt-get not found. Using alternative installation methods..."
      # Fall back to direct binary downloads
    else
      sudo apt-get update
      sudo apt-get install -y curl wget jq
    fi
    
    # Install k3d
    if ! command -v k3d &> /dev/null; then
      echo "📦 Installing k3d..."
      wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    fi
    
    # Install kubectl
    if ! command -v kubectl &> /dev/null; then
      echo "📦 Installing kubectl..."
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
    fi
    
    # Install terraform
    if ! command -v terraform &> /dev/null; then
      echo "📦 Installing terraform..."
      wget -q https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
      unzip -q terraform_1.5.7_linux_amd64.zip
      sudo mv terraform /usr/local/bin/
      rm terraform_1.5.7_linux_amd64.zip
    fi
    
    # Install helm
    if ! command -v helm &> /dev/null; then
      echo "📦 Installing helm..."
      curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    ;;
  msys*|cygwin*|win32)
    echo "✅ Windows detected - using Chocolatey"
    if ! command -v choco &> /dev/null; then
      echo "❌ Chocolatey not found. Please install it from https://chocolatey.org"
      exit 1
    fi
    echo "📦 Installing prerequisites..."
    choco install k3d kubectl terraform helm jq -y
    ;;
  *)
    echo "❌ Unsupported operating system: $OSTYPE"
    echo "Please install manually: k3d, kubectl, terraform, helm, jq"
    exit 1
    ;;
esac

echo "✅ All prerequisites installed successfully!"
echo ""
echo "Verifying installations:"
k3d version
kubectl version --client
terraform version
helm version
jq --version
