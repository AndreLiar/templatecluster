#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME=${1}
TIMEOUT=${2:-600}

if [ -z "$CLUSTER_NAME" ]; then
  echo -e "${RED}Error: Cluster name is required${NC}"
  echo "Usage: $0 <cluster-name> [timeout-seconds]"
  echo "Example: $0 HDI-dev 600"
  exit 1
fi

CONTEXT="k3d-${CLUSTER_NAME}"

echo -e "${YELLOW}Waiting for cluster ${CLUSTER_NAME} to be ready...${NC}"
echo "Context: ${CONTEXT}"
echo "Timeout: ${TIMEOUT} seconds"
echo ""

# Check cluster exists
echo -n "Checking if cluster exists... "
if ! kubectl cluster-info --context="${CONTEXT}" >/dev/null 2>&1; then
  echo -e "${RED}FAILED${NC}"
  echo -e "${RED}Error: Cluster ${CLUSTER_NAME} not found or not accessible${NC}"
  echo ""
  echo "Available k3d clusters:"
  k3d cluster list
  exit 1
fi
echo -e "${GREEN}OK${NC}"

# Wait for all nodes to be ready
echo -n "Waiting for nodes to be ready... "
start_time=$(date +%s)
while true; do
  if kubectl wait --for=condition=Ready nodes --all \
    --context="${CONTEXT}" --timeout=30s >/dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
    break
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $TIMEOUT ]; then
    echo -e "${RED}TIMEOUT${NC}"
    exit 1
  fi
  sleep 5
done

# Wait for system pods
echo -n "Waiting for kube-system pods... "
start_time=$(date +%s)
while true; do
  ready_pods=$(kubectl get pods -n kube-system --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | awk '{print $2}' | grep -c "^[0-9]*/[0-9]*$" || true)
  total_pods=$(kubectl get pods -n kube-system --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | wc -l || true)

  if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
    all_ready=true
    while IFS= read -r line; do
      ready=$(echo "$line" | awk '{print $2}' | cut -d'/' -f1)
      total=$(echo "$line" | awk '{print $2}' | cut -d'/' -f2)
      if [ "$ready" != "$total" ]; then
        all_ready=false
        break
      fi
    done < <(kubectl get pods -n kube-system --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed")

    if [ "$all_ready" = true ]; then
      echo -e "${GREEN}OK (${total_pods} pods)${NC}"
      break
    fi
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $TIMEOUT ]; then
    echo -e "${RED}TIMEOUT${NC}"
    kubectl get pods -n kube-system --context="${CONTEXT}"
    exit 1
  fi
  sleep 5
done

# Wait for ingress-nginx namespace
echo -n "Waiting for ingress-nginx pods... "
start_time=$(date +%s)
while true; do
  if kubectl get namespace ingress-nginx --context="${CONTEXT}" >/dev/null 2>&1; then
    ready_pods=$(kubectl get pods -n ingress-nginx --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | awk '{print $2}' | grep -c "^[0-9]*/[0-9]*$" || true)
    total_pods=$(kubectl get pods -n ingress-nginx --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | wc -l || true)

    if [ "$total_pods" -gt 0 ]; then
      all_ready=true
      while IFS= read -r line; do
        ready=$(echo "$line" | awk '{print $2}' | cut -d'/' -f1)
        total=$(echo "$line" | awk '{print $2}' | cut -d'/' -f2)
        if [ "$ready" != "$total" ]; then
          all_ready=false
          break
        fi
      done < <(kubectl get pods -n ingress-nginx --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed")

      if [ "$all_ready" = true ]; then
        echo -e "${GREEN}OK (${total_pods} pods)${NC}"
        break
      fi
    fi
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $TIMEOUT ]; then
    echo -e "${YELLOW}TIMEOUT (namespace may not exist yet)${NC}"
    break
  fi
  sleep 5
done

# Wait for monitoring namespace
echo -n "Waiting for monitoring pods... "
start_time=$(date +%s)
while true; do
  if kubectl get namespace monitoring --context="${CONTEXT}" >/dev/null 2>&1; then
    ready_pods=$(kubectl get pods -n monitoring --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | awk '{print $2}' | grep -c "^[0-9]*/[0-9]*$" || true)
    total_pods=$(kubectl get pods -n monitoring --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | wc -l || true)

    if [ "$total_pods" -gt 0 ]; then
      all_ready=true
      while IFS= read -r line; do
        ready=$(echo "$line" | awk '{print $2}' | cut -d'/' -f1)
        total=$(echo "$line" | awk '{print $2}' | cut -d'/' -f2)
        if [ "$ready" != "$total" ]; then
          all_ready=false
          break
        fi
      done < <(kubectl get pods -n monitoring --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed")

      if [ "$all_ready" = true ]; then
        echo -e "${GREEN}OK (${total_pods} pods)${NC}"
        break
      fi
    fi
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $TIMEOUT ]; then
    echo -e "${YELLOW}TIMEOUT (namespace may not exist yet)${NC}"
    break
  fi
  sleep 5
done

# Wait for ArgoCD namespace
echo -n "Waiting for ArgoCD pods... "
start_time=$(date +%s)
while true; do
  if kubectl get namespace argocd --context="${CONTEXT}" >/dev/null 2>&1; then
    ready_pods=$(kubectl get pods -n argocd --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | awk '{print $2}' | grep -c "^[0-9]*/[0-9]*$" || true)
    total_pods=$(kubectl get pods -n argocd --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | wc -l || true)

    if [ "$total_pods" -gt 0 ]; then
      all_ready=true
      while IFS= read -r line; do
        ready=$(echo "$line" | awk '{print $2}' | cut -d'/' -f1)
        total=$(echo "$line" | awk '{print $2}' | cut -d'/' -f2)
        if [ "$ready" != "$total" ]; then
          all_ready=false
          break
        fi
      done < <(kubectl get pods -n argocd --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed")

      if [ "$all_ready" = true ]; then
        echo -e "${GREEN}OK (${total_pods} pods)${NC}"
        break
      fi
    fi
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $TIMEOUT ]; then
    echo -e "${YELLOW}TIMEOUT (namespace may not exist yet)${NC}"
    break
  fi
  sleep 5
done

echo ""
echo -e "${GREEN}=== Cluster Health Summary ===${NC}"
echo ""

# Show node status
echo "Nodes:"
kubectl get nodes --context="${CONTEXT}"
echo ""

# Show pod status by namespace
echo "Pods by Namespace:"
for ns in kube-system ingress-nginx monitoring argocd; do
  if kubectl get namespace $ns --context="${CONTEXT}" >/dev/null 2>&1; then
    pod_count=$(kubectl get pods -n $ns --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | wc -l)
    ready_count=$(kubectl get pods -n $ns --context="${CONTEXT}" --no-headers 2>/dev/null | grep -v "Completed" | grep -c "Running" || true)
    echo "  ${ns}: ${ready_count}/${pod_count} Running"
  fi
done
echo ""

echo -e "${GREEN}✅ Cluster ${CLUSTER_NAME} is ready!${NC}"
echo ""
echo "You can now access your services:"
echo "  kubectl get all --all-namespaces --context=${CONTEXT}"
