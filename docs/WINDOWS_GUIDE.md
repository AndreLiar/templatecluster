# 🪟 Windows Installation & Usage Guide

## 📋 Prerequisites

### Required Software

1. **Docker Desktop for Windows**
   ```powershell
   # Download from: https://www.docker.com/products/docker-desktop
   # Install and enable WSL2 backend (recommended)
   ```

2. **Install Chocolatey** (Windows Package Manager)
   ```powershell
   # Run as Administrator in PowerShell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

3. **Install Tools**
   ```powershell
   # Run as Administrator
   choco install kubernetes-cli terraform helm git -y
   
   # Install k3d
   choco install k3d -y
   # Or manually: https://k3d.io/v5.6.0/#installation
   ```

---

## 🎯 Three Ways to Use on Windows

### Option 1: WSL2 (RECOMMENDED) ⭐

**Why:** Native Linux experience, all bash scripts work perfectly

```powershell
# 1. Install WSL2
wsl --install

# 2. Restart your computer

# 3. Open Ubuntu (from Start menu)
# Inside Ubuntu terminal:
sudo apt update
sudo apt install -y curl git

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 4. Use normally!
git clone YOUR_TEMPLATE_REPO
cd k8s-cluster-template
./scripts/init-template.sh     # Works perfectly!
./scripts/quick-deploy.sh myproject https://github.com/org/repo dev
```

**Access Services:**
- Services are accessible at `localhost:30xxx` from Windows browser
- Docker Desktop bridges WSL2 to Windows

---

### Option 2: Git Bash

**Why:** Simpler than WSL2, most scripts will work

```bash
# 1. Install Git for Windows (includes Git Bash)
# Download: https://git-scm.com/download/win

# 2. Install tools via Chocolatey (PowerShell as Admin)
choco install kubernetes-cli terraform k3d helm -y

# 3. Open "Git Bash" (not PowerShell)
git clone YOUR_TEMPLATE_REPO
cd k8s-cluster-template

# 4. Use bash scripts
./scripts/init-template.sh
./scripts/create-cluster.sh dev
```

**Known Issues:**
- Some sed commands might not work perfectly
- Path conversions (Windows vs Unix paths)
- Better to use WSL2 for production use

---

### Option 3: Native PowerShell

**Why:** Pure Windows, no Linux layer needed

#### Setup
```powershell
# 1. Install tools (PowerShell as Admin)
choco install kubernetes-cli terraform k3d helm git -y

# 2. Set execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Clone template
git clone YOUR_TEMPLATE_REPO
cd k8s-cluster-template
```

#### Usage with PowerShell Scripts

**Interactive Setup:**
```powershell
.\scripts\init-template.ps1
```

**Quick Deploy:**
```powershell
.\scripts\quick-deploy.ps1 -ProjectName "myapp" -GitRepo "https://github.com/org/repo" -Environment "dev"
```

**Manual Deployment:**
```powershell
cd terraform\environments\dev

# Edit terraform.tfvars
notepad terraform.tfvars

# Deploy
terraform init
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve
```

---

## 🔧 Windows-Specific Commands

### PowerShell Equivalents

| Bash | PowerShell |
|------|------------|
| `ls -la` | `Get-ChildItem` or `ls` |
| `cat file.txt` | `Get-Content file.txt` or `cat file.txt` |
| `grep pattern` | `Select-String pattern` |
| `export VAR=value` | `$env:VAR = "value"` |
| `./script.sh` | `.\script.ps1` |

### Path Differences

```powershell
# Linux/Mac
cd ~/projects
./scripts/deploy.sh

# Windows PowerShell
cd ~\projects
.\scripts\deploy.ps1

# Windows Git Bash
cd ~/projects
./scripts/deploy.sh
```

---

## 🐛 Common Windows Issues & Fixes

### Issue 1: "Cannot run scripts"
```powershell
# Solution: Set execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 2: "k3d not found"
```powershell
# Solution: Ensure Docker Desktop is running
# Check: Docker Desktop → Settings → Enable WSL2

# Restart PowerShell after installation
refreshenv

# Verify
k3d version
```

### Issue 3: "Port already in use"
```powershell
# Find process using port
netstat -ano | findstr :30200

# Kill process (replace PID)
taskkill /PID <PID> /F
```

### Issue 4: "Line ending issues"
```bash
# If files show ^M characters
# In Git Bash:
dos2unix scripts/*.sh

# Or configure Git:
git config --global core.autocrlf input
```

### Issue 5: "Context not found"
```powershell
# Apply in two stages
cd terraform\environments\dev
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve
```

---

## 📂 Directory Structure (Windows)

```
C:\Users\YourName\projects\k8s-cluster-template\
├── scripts\
│   ├── init-template.sh         # Use in Git Bash/WSL2
│   ├── init-template.ps1        # Use in PowerShell
│   ├── quick-deploy.sh          # Use in Git Bash/WSL2
│   ├── quick-deploy.ps1         # Use in PowerShell
│   └── ...
├── terraform\
│   ├── modules\
│   └── environments\
│       ├── dev\
│       ├── staging\
│       └── prod\
└── docs\
```

---

## 🎯 Recommended Workflow for Windows

### For Developers (Simplest)
1. **Install WSL2**
2. **Use Ubuntu terminal**
3. **All bash scripts work**
4. **Access via Windows browser**

### For Windows-Only Environments
1. **Install Git Bash**
2. **Use provided bash scripts**
3. **Fall back to PowerShell if needed**

### For PowerShell Users
1. **Use `.ps1` scripts**
2. **Terraform commands work identically**
3. **kubectl commands work identically**

---

## 🚀 Quick Start (Windows)

### WSL2 Method (Recommended)
```bash
# In Ubuntu terminal
git clone YOUR_TEMPLATE
cd k8s-cluster-template
./scripts/init-template.sh
./scripts/create-cluster.sh dev

# Access from Windows browser
# http://localhost:30200 (ArgoCD)
# http://localhost:30300 (Grafana)
```

### Git Bash Method
```bash
# In Git Bash
git clone YOUR_TEMPLATE
cd k8s-cluster-template
./scripts/init-template.sh
./scripts/create-cluster.sh dev
```

### PowerShell Method
```powershell
# In PowerShell
git clone YOUR_TEMPLATE
cd k8s-cluster-template
.\scripts\init-template.ps1

# Manual deploy
cd terraform\environments\dev
terraform init
terraform apply -target=module.k3d_cluster -auto-approve
terraform apply -auto-approve
```

---

## 📊 Comparison

| Feature | WSL2 | Git Bash | PowerShell |
|---------|------|----------|------------|
| **Ease of Setup** | Medium | Easy | Easy |
| **Script Compatibility** | 100% | 90% | 60% (need .ps1) |
| **Performance** | Excellent | Good | Excellent |
| **Windows Integration** | Good | Excellent | Native |
| **Recommended?** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🎓 Learning Resources

- **WSL2**: https://learn.microsoft.com/en-us/windows/wsl/install
- **PowerShell**: https://learn.microsoft.com/en-us/powershell/
- **Docker Desktop**: https://docs.docker.com/desktop/windows/
- **Chocolatey**: https://chocolatey.org/install

---

## ✅ Verification Checklist

After installation, verify everything works:

```powershell
# Check all tools
docker --version
kubectl version --client
terraform --version
k3d version
helm version

# Check Docker is running
docker ps

# Test k3d
k3d cluster create test
k3d cluster delete test
```

---

**🎉 You're ready! Choose your preferred method and deploy!**

**Recommendation:** Start with **WSL2** for the best experience.
