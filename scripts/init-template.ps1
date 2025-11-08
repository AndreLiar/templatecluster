# Windows PowerShell - Init Template
# Usage: .\init-template.ps1

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║   K8s Cluster Template Initialization (Windows)  ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Collect information
$ProjectName = Read-Host "Enter your project name (e.g., myapp)"
$GitRepoUrl = Read-Host "Enter Git repository URL"
$GitUsername = Read-Host "Enter Git username"
$GitPassword = Read-Host "Enter Git password/token" -AsSecureString
$GitPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($GitPassword))
$ArgoCDPassword = Read-Host "Enter ArgoCD admin password"

if (!$ProjectName -or !$GitRepoUrl -or !$GitUsername -or !$GitPasswordPlain) {
    Write-Host "Error: All fields are required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Configuration Summary ===" -ForegroundColor Yellow
Write-Host "Project Name: $ProjectName"
Write-Host "Git Repository: $GitRepoUrl"
Write-Host "Git Username: $GitUsername"
Write-Host ""

$Confirm = Read-Host "Proceed with initialization? (y/n)"
if ($Confirm -ne "y" -and $Confirm -ne "Y") {
    Write-Host "Initialization cancelled"
    exit 0
}

Write-Host ""
Write-Host "=== Updating Configuration Files ===" -ForegroundColor Blue

# Update cluster names in main.tf files
$environments = @("dev", "staging", "prod")
foreach ($env in $environments) {
    $mainTf = "terraform\environments\$env\main.tf"
    if (Test-Path $mainTf) {
        Write-Host "✓ Updating $env/main.tf" -ForegroundColor Green
        (Get-Content $mainTf) -replace 'cluster_name = "ktayl-\$\{local.environment\}"', "cluster_name = `"$ProjectName-`${local.environment}`"" | Set-Content $mainTf
    }
}

# Update .tfvars files
foreach ($env in $environments) {
    $tfvarsFile = "terraform\environments\$env\terraform.tfvars"
    
    if (Test-Path $tfvarsFile) {
        Write-Host "✓ Updating $env/terraform.tfvars" -ForegroundColor Green
        
        $content = Get-Content $tfvarsFile
        $content = $content -replace 'git_repo_url\s*=.*', "git_repo_url = `"$GitRepoUrl`""
        $content = $content -replace 'git_username\s*=.*', "git_username = `"$GitUsername`""
        $content = $content -replace 'git_password\s*=.*', "git_password = `"$GitPasswordPlain`""
        
        if ($ArgoCDPassword) {
            $content = $content -replace 'argocd_admin_password\s*=.*', "argocd_admin_password = `"$ArgoCDPassword`""
        }
        
        Set-Content -Path $tfvarsFile -Value $content
    }
}

Write-Host ""
Write-Host "=== Creating Example Files ===" -ForegroundColor Blue

# Create .tfvars.example files
foreach ($env in $environments) {
    $exampleFile = "terraform\environments\$env\terraform.tfvars.example"
    
    $exampleContent = @"
# Git Repository Configuration
git_repo_url  = "$GitRepoUrl"
git_username  = "your-git-username"
git_password  = "your-git-token-or-password"

# ArgoCD Configuration
argocd_admin_password = "your-secure-password"
"@
    
    Set-Content -Path $exampleFile -Value $exampleContent
    Write-Host "✓ Created $env/terraform.tfvars.example" -ForegroundColor Green
}

# Create .gitignore if it doesn't exist
if (!(Test-Path ".gitignore")) {
    Write-Host "✓ Creating .gitignore" -ForegroundColor Green
    
    $gitignoreContent = @"
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
.terraform.lock.hcl
*.tfplan

# Sensitive files
**/terraform.tfvars
!**/terraform.tfvars.example

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
"@
    
    Set-Content -Path ".gitignore" -Value $gitignoreContent
}

# Update README
if (Test-Path "README.md") {
    Write-Host "✓ Updating README.md" -ForegroundColor Green
    (Get-Content "README.md") -replace 'KtaylBusiness', $ProjectName -replace 'ktayl', $ProjectName | Set-Content "README.md"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        🎉 Initialization Complete!               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the generated configuration files"
Write-Host "2. Deploy your first environment:"
Write-Host ""
Write-Host "   cd terraform\environments\dev" -ForegroundColor Blue
Write-Host "   terraform init" -ForegroundColor Blue
Write-Host "   terraform apply -target=module.k3d_cluster -auto-approve" -ForegroundColor Blue
Write-Host "   terraform apply -auto-approve" -ForegroundColor Blue
Write-Host ""
Write-Host "3. Or use the PowerShell script:" -ForegroundColor Yellow
Write-Host "   .\scripts\quick-deploy.ps1 -ProjectName $ProjectName -GitRepo $GitRepoUrl -Environment dev" -ForegroundColor Blue
Write-Host ""
Write-Host "Access URLs (after deployment):" -ForegroundColor Yellow
Write-Host "  Dev ArgoCD:       http://localhost:30200"
Write-Host "  Dev Grafana:      http://localhost:30300"
Write-Host "  Dev Prometheus:   http://localhost:30090"
Write-Host ""
Write-Host "Credentials:" -ForegroundColor Yellow
Write-Host "  ArgoCD:  admin / $ArgoCDPassword"
Write-Host "  Grafana: admin / enterprise123"
Write-Host ""
