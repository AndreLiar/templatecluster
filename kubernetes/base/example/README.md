# Example Applications

This directory contains example Kubernetes manifests that are managed by ArgoCD.

## nginx-demo

A simple nginx deployment demonstrating GitOps workflow:
- 2 replicas for high availability
- Resource limits configured
- ClusterIP service

## How It Works

1. ArgoCD monitors this directory via the bootstrap application
2. Any changes pushed to Git are automatically synced to the cluster
3. ArgoCD ensures the cluster state matches the Git repository

## Adding New Applications

1. Create your Kubernetes manifests in this directory
2. Commit and push to Git
3. ArgoCD will automatically detect and deploy

## Viewing in ArgoCD

Access ArgoCD UI at http://localhost:30200 to see:
- Sync status
- Resource health
- Deployment history
- Diff between Git and cluster state
