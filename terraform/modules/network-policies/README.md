# Network Policies Module

## Overview

This module implements Kubernetes Network Policies to provide network segmentation and security hardening for the cluster.

## Deployment Profiles

Network policies are **disabled by default** and only enabled in the `full` deployment profile:

- **minimal**: Network policies disabled
- **standard**: Network policies disabled  
- **full**: Network policies **enabled**

## Enabling Network Policies

### Option 1: Use Full Profile

```bash
cd terraform/environments/dev
terraform apply -var="deployment_profile=full"
```

### Option 2: Modify Profile Configuration

Edit `terraform/environments/dev/profiles.tf` and set `network_policies = true` for your desired profile.

## What Gets Created

When enabled, the following network policies are applied:

1. **Default Deny All Ingress** - Blocks all incoming traffic by default
2. **Allow DNS** - Permits DNS queries to kube-dns
3. **Allow Monitoring** - Permits Prometheus to scrape metrics
4. **Allow Ingress Controller** - Permits NGINX ingress traffic

## Impact

⚠️ **Important:** Enabling network policies will:

- Block all pod-to-pod communication by default
- Require explicit policies for any new services
- May break applications that don't have policies defined

## Testing Network Policies

After enabling:

```bash
# Verify policies are created
kubectl get networkpolicies -A --context k3d-HDI-dev

# Test connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -O- http://service-name
```

## Adding Custom Policies

Create additional policies in `terraform/modules/network-policies/policies.tf`:

```hcl
resource "kubernetes_network_policy" "my_policy" {
  metadata {
    name      = "my-policy"
    namespace = "my-namespace"
  }
  
  spec {
    pod_selector {
      match_labels = {
        app = "my-app"
      }
    }
    
    policy_types = ["Ingress"]
    
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "allowed-app"
          }
        }
      }
    }
  }
}
```

## Troubleshooting

If services stop working after enabling network policies:

1. Check pod logs for connection errors
2. Verify network policies exist: `kubectl get netpol -A`
3. Add explicit allow policies for your services
4. Temporarily disable by switching to `standard` profile

## Production Recommendations

For production environments:

1. Start with network policies disabled
2. Map all service-to-service communication
3. Create policies for each communication path
4. Enable policies in staging first
5. Monitor for connectivity issues
6. Roll out to production

## References

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
