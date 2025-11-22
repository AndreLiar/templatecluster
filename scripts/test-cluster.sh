#!/bin/bash
# Automated cluster validation

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}Usage: $0 {dev|staging|prod}${NC}"
    exit 1
fi

# Determine cluster name
case "$ENVIRONMENT" in
  dev)
    CLUSTER_NAME="HDI-dev"
    ;;
  staging)
    CLUSTER_NAME="HDI-stage"
    ;;
  prod)
    CLUSTER_NAME="HDI-prod"
    ;;
  *)
    echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
    exit 1
    ;;
esac

CONTEXT="k3d-${CLUSTER_NAME}"
  echo "✓ PASS"
else
  echo "✗ FAIL (might be expected if using NodePort without port forwarding or if service is not ready)"
  # Don't fail the script for this as it depends on local environment
fi

echo -n "Testing Grafana UI... "
if curl -s http://localhost:${GRAFANA_PORT:-30300}/api/health | grep -q "ok"; then
  echo "✓ PASS"
else
  echo "✗ FAIL (might be expected if using NodePort without port forwarding or if service is not ready)"
fi

echo ""
if [ $FAILED -eq 0 ]; then
  echo "✅ All component tests passed!"
  exit 0
else
  echo "❌ ${FAILED} component tests failed"
  exit 1
fi
