# ArgoCD GitOps Setup

## Overview

This directory contains ArgoCD Application manifests for GitOps automation.

## Bootstrap Application

The `bootstrap-app.yaml` is the root application that manages other applications in the `kubernetes/applications` directory.

## Deploying the Bootstrap App

After cluster creation, apply the bootstrap application:

```bash
kubectl apply -f kubernetes/argocd/bootstrap-app.yaml --context k3d-HDI-dev
```

This will:
1. Create the bootstrap application in ArgoCD
2. Automatically sync applications from `kubernetes/applications/`
3. Enable GitOps workflow for all managed applications

## Adding New Applications

1. Create a new Application manifest in `kubernetes/applications/`
2. Commit and push to your Git repository
3. ArgoCD will automatically detect and sync the new application

## Accessing ArgoCD UI

```bash
# Get admin password
cat terraform/environments/dev/.credentials

# Access UI
open http://localhost:30200
```

## Manual Sync

If needed, you can manually sync applications:

```bash
# Via CLI
argocd app sync bootstrap --context k3d-HDI-dev

# Via UI
Navigate to http://localhost:30200 and click "Sync"
```
