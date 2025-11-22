# Cluster Health Test Script (PowerShell)
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment
)

# Colors
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Cyan"

# Determine cluster name
$ClusterName = switch ($Environment) {
    "dev" { "HDI-dev" }
    "staging" { "HDI-stage" }
    "prod" { "HDI-prod" }
}

$Context = "k3d-$ClusterName"

Write-Host "`n=== Testing $Environment Environment ($ClusterName) ===" -ForegroundColor $Blue

# Test cluster connectivity
Write-Host "`nChecking cluster connectivity..." -ForegroundColor $Blue
try {
    kubectl cluster-info --context $Context | Out-Null
    Write-Host "✓ Cluster is accessible" -ForegroundColor $Green
}
catch {
    Write-Host "✗ Cannot connect to cluster" -ForegroundColor $Red
    exit 1
}

# Check ArgoCD
Write-Host "`nChecking ArgoCD..." -ForegroundColor $Blue
$argoPods = kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --context $Context -o json 2>$null | ConvertFrom-Json
if ($argoPods.items.Count -gt 0 -and $argoPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ ArgoCD is running" -ForegroundColor $Green
    
    # Test ArgoCD API
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:30200/healthz" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ ArgoCD API is accessible" -ForegroundColor $Green
        }
    }
    catch {
        Write-Host "⚠ ArgoCD API not responding" -ForegroundColor $Yellow
    }
}
else {
    Write-Host "✗ ArgoCD is not running" -ForegroundColor $Red
}

# Check Prometheus
Write-Host "`nChecking Prometheus..." -ForegroundColor $Blue
$promPods = kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --context $Context -o json 2>$null | ConvertFrom-Json
if ($promPods.items.Count -gt 0 -and $promPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ Prometheus is running" -ForegroundColor $Green
}
else {
    Write-Host "✗ Prometheus is not running" -ForegroundColor $Red
}

# Check Grafana
Write-Host "`nChecking Grafana..." -ForegroundColor $Blue
$grafanaPods = kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --context $Context -o json 2>$null | ConvertFrom-Json
if ($grafanaPods.items.Count -gt 0 -and $grafanaPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ Grafana is running" -ForegroundColor $Green
    
    # Test Grafana API
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:30300/api/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Grafana API is accessible" -ForegroundColor $Green
        }
    }
    catch {
        Write-Host "⚠ Grafana API not responding" -ForegroundColor $Yellow
    }
}
else {
    Write-Host "✗ Grafana is not running" -ForegroundColor $Red
}

# Check NGINX Ingress
Write-Host "`nChecking NGINX Ingress..." -ForegroundColor $Blue
$ingressPods = kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --context $Context -o json 2>$null | ConvertFrom-Json
if ($ingressPods.items.Count -gt 0 -and $ingressPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ NGINX Ingress is running" -ForegroundColor $Green
}
else {
    Write-Host "✗ NGINX Ingress is not running" -ForegroundColor $Red
}

# Check Sealed Secrets
Write-Host "`nChecking Sealed Secrets..." -ForegroundColor $Blue
$sealedPods = kubectl get pods -n kube-system -l app.kubernetes.io/name=sealed-secrets --context $Context -o json 2>$null | ConvertFrom-Json
if ($sealedPods.items.Count -gt 0 -and $sealedPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ Sealed Secrets is running" -ForegroundColor $Green
}
else {
    Write-Host "⚠ Sealed Secrets is not running (may be disabled in profile)" -ForegroundColor $Yellow
}

# Check Cert-Manager
Write-Host "`nChecking Cert-Manager..." -ForegroundColor $Blue
$certPods = kubectl get pods -n cert-manager -l app.kubernetes.io/name=cert-manager --context $Context -o json 2>$null | ConvertFrom-Json
if ($certPods.items.Count -gt 0 -and $certPods.items[0].status.phase -eq "Running") {
    Write-Host "✓ Cert-Manager is running" -ForegroundColor $Green
}
else {
    Write-Host "⚠ Cert-Manager is not running (may be disabled in profile)" -ForegroundColor $Yellow
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor $Blue
Write-Host "Environment: $Environment" -ForegroundColor $Blue
Write-Host "Cluster: $ClusterName" -ForegroundColor $Blue
Write-Host "Context: $Context" -ForegroundColor $Blue

Write-Host "`nAccess URLs:" -ForegroundColor $Blue
Write-Host "  ArgoCD:       http://localhost:30200" -ForegroundColor $Green
Write-Host "  Grafana:      http://localhost:30300" -ForegroundColor $Green
Write-Host "  Prometheus:   http://localhost:30090" -ForegroundColor $Green
Write-Host "  Alertmanager: http://localhost:30094" -ForegroundColor $Green
Write-Host "  NGINX HTTP:   http://localhost:30080" -ForegroundColor $Green
Write-Host "  NGINX HTTPS:  https://localhost:30443" -ForegroundColor $Green

Write-Host "`nTest completed successfully!`n" -ForegroundColor $Green
