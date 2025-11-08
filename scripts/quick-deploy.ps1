# Windows PowerShell Version - Quick Deploy
# Usage: .\quick-deploy.ps1 -ProjectName "myproject" -GitRepo "https://github.com/org/repo" -Environment "dev"

param(
    [string]$ProjectName = "myproject",
    [string]$GitRepo = "https://github.com/example/repo",
    [string]$Environment = "dev"
)

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║      Quick Deploy - K8s Cluster (Windows)        ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""
Write-Host "Project: $ProjectName" -ForegroundColor Cyan
Write-Host "Git Repo: $GitRepo" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
$commands = @("k3d", "kubectl", "terraform", "helm")
foreach ($cmd in $commands) {
    if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Error: $cmd is not installed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ $cmd found" -ForegroundColor Green
}

# Navigate to environment
$envDir = "terraform\environments\$Environment"
if (!(Test-Path $envDir)) {
    Write-Host "Environment $Environment not found. Using dev." -ForegroundColor Yellow
    $envDir = "terraform\environments\dev"
}

Set-Location $envDir

# Check if tfvars exists
if (!(Test-Path "terraform.tfvars")) {
    Write-Host "Creating terraform.tfvars..." -ForegroundColor Yellow
    
    $tfvarsContent = @"
git_repo_url  = "$GitRepo"
git_username  = "$env:GIT_USERNAME"
git_password  = "$env:GIT_PASSWORD"
argocd_admin_password = "Nightagent2025@"
"@
    
    Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
}

Write-Host "=== Initializing Terraform ===" -ForegroundColor Green
terraform init

Write-Host "=== Creating Cluster ===" -ForegroundColor Green
terraform apply -target=module.k3d_cluster -auto-approve

Write-Host "=== Deploying Components ===" -ForegroundColor Green
terraform apply -auto-approve

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          🎉 Deployment Complete!                 ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Get ports based on environment
$ports = @{
    "dev" = @{argocd="30200"; grafana="30300"; prometheus="30090"}
    "staging" = @{argocd="31200"; grafana="31300"; prometheus="31090"}
    "prod" = @{argocd="32200"; grafana="32300"; prometheus="32090"}
}

$envPorts = $ports[$Environment]
if (!$envPorts) { $envPorts = $ports["dev"] }

Write-Host "Access URLs:" -ForegroundColor Yellow
Write-Host "  ArgoCD:     http://localhost:$($envPorts.argocd)"
Write-Host "  Grafana:    http://localhost:$($envPorts.grafana)"
Write-Host "  Prometheus: http://localhost:$($envPorts.prometheus)"
Write-Host ""
Write-Host "Credentials:" -ForegroundColor Yellow
Write-Host "  ArgoCD:  admin / Nightagent2025@"
Write-Host "  Grafana: admin / enterprise123"
Write-Host ""
