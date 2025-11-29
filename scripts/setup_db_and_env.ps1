<#
PowerShell helper: setup_db_and_env.ps1
- Pulls Terraform outputs for Postgres
- Adds firewall rules for current IP and bastion IP
- Creates app user `shortify_user` and DB `shortifyaf`
- Builds a DATABASE_URL and writes `backend/.env` locally (NOT committed)
- Optionally writes repo secret `DATABASE_URL` (requires GitHub CLI auth)

Usage:
  cd <repo root>
  pwsh .\scripts\setup_db_and_env.ps1 -AdminPassword '<admin_password>' -AppPassword 'Testing123$' -PushGitHubSecret

Notes:
  - Requires: terraform, az, docker (or psql), gh (optional) installed and logged in
  - Do NOT commit .env to Git
  - This script uses docker postgres client for psql commands to avoid local install
  - It uses terraform to pull outputs. Make sure `terraform` is configured and `terraform init` has run.
#>
param(
  [Parameter(Mandatory=$false)]
  [string]$AdminPassword,

  [Parameter(Mandatory=$false)]
  [string]$AppPassword = "Testing123$",

  [Parameter(Mandatory=$false)]
  [switch]$PushGitHubSecret,

  [Parameter(Mandatory=$false)]
  [string]$PrivateKeyPath = "$env:USERPROFILE/.ssh/id_rsa",

  [Parameter(Mandatory=$false)]
  [string]$VMUser = 'azureuser'
)

function ThrowIfMissingTool($tool) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    throw "Required tool '$tool' is not installed or not in PATH. Please install it before running this script." 
  }
}

# Prereqs
ThrowIfMissingTool terraform
ThrowIfMissingTool az
ThrowIfMissingTool docker
# gh is optional

# Move to terraform folder for TF outputs
Push-Location -Path (Join-Path $PSScriptRoot '..\terraform')

$TFPath = 'C:\Program Files\Terraform\terraform.exe'
if (Test-Path $TFPath) {
  $TF = "$TFPath"
} elseif (Get-Command terraform -ErrorAction SilentlyContinue) {
  $TF = 'terraform'
} else {
  Throw "terraform isn't available; please install and add it to PATH."
}

# Initialize to ensure outputs are accessible
Write-Host "Ensuring terraform init is configured..."
& $TF init -reconfigure | Out-Null

# Get TF outputs
function TFOut($name) {
  $val = & $TF output -raw $name 2>$null
  return $val
}

$PG_FQDN = TFOut 'postgres_fqdn'
$PG_ADMIN = TFOut 'postgres_admin_user'
$PG_PASS = TFOut 'postgres_admin_password'
$BASTION_IP = TFOut 'bastion_public_ip'
$APP_PUBLIC_IP = TFOut 'app_public_ip'

Pop-Location

if (-not $PG_FQDN) { throw "Cannot read terraform output 'postgres_fqdn'. Make sure terraform has expected outputs and state." }
if (-not $PG_ADMIN) { Write-Host "Warning: TF output 'postgres_admin_user' empty, defaulting to 'pgadmin'"; $PG_ADMIN = 'pgadmin' }

if (-not $PG_PASS -and -not $AdminPassword) {
  # If the admin password isn't in MT outputs but the TF random password is in state, it may be sensitive; prompt user
  $AdminPassword = Read-Host -AsSecureString -Prompt "Enter the Postgres admin password (or ensure TF outputs include it)" | ConvertFrom-SecureString -AsPlainText
}
elseif ($AdminPassword) {
  $PG_PASS = $AdminPassword
}

if (-not $PG_PASS) { throw "Admin password is required. Provide with -AdminPassword or ensure TF outputs include it." }

# Short helper values
$PG_SERVER = $PG_FQDN.Split('.')[0]

# Detect public IP
$MY_IP = (Invoke-RestMethod -Uri 'https://ipinfo.io/ip').Trim()
Write-Host "Detected public IP: $MY_IP"

# Add firewall rules (idempotent)
Write-Host "Adding firewall rules for My IP and Bastion IP..."
az postgres flexible-server firewall-rule create -g shortifyaf-rg -s $PG_SERVER -n allowMyIP --start-ip-address $MY_IP --end-ip-address $MY_IP 2>$null | Out-Null
if ($BASTION_IP) { az postgres flexible-server firewall-rule create -g shortifyaf-rg -s $PG_SERVER -n allowBastion --start-ip-address $BASTION_IP --end-ip-address $BASTION_IP 2>$null | Out-Null }

# Create DB user and DB using Docker psql
$escapedAppPass = $AppPassword -replace '\$','`$'  # escape $ in PowerShell variable for later usage
# Commands to run inside Docker
$createCommands = @(
  "CREATE ROLE shortify_user WITH LOGIN PASSWORD '$AppPassword';",
  "CREATE DATABASE shortifyaf OWNER shortify_user;",
  "GRANT ALL PRIVILEGES ON DATABASE shortifyaf TO shortify_user;"
)

foreach ($cmd in $createCommands) {
  Write-Host "Running: $cmd"
  docker run --rm -e PGPASSWORD=$PG_PASS postgres:13 psql -h $PG_FQDN -U "$PG_ADMIN@$PG_SERVER" -d postgres -c "$cmd"
}

# Compose DATABASE_URL
$DB_URL = "postgres://shortify_user:$($AppPassword)@$PG_FQDN:5432/shortifyaf?sslmode=require"
# Write local backend .env (non-committed)
$envContent = @"PORT=3001
DATABASE_URL=$DB_URL
FRONTEND_URL=http://localhost:5173
"@
Set-Content -Path "$(Join-Path $PSScriptRoot '..\backend\.env')" -Value $envContent -Force
Write-Host "Wrote backend .env with the app connection string (not committed)."

# Optional: set GitHub secrets if requested
if ($PushGitHubSecret) {
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Host "gh (GitHub CLI) not found; skipping GH secret push" } else {
    # Change to repo root and set secret
    Push-Location -Path (Join-Path $PSScriptRoot '..')
    gh secret set DATABASE_URL --body $DB_URL
    gh secret set DB_USER --body "shortify_user"
    gh secret set DB_PASS --body $AppPassword
    Pop-Location
    Write-Host "Pushed DATABASE_URL, DB_USER, DB_PASS to GitHub Secrets."
  }
}

Write-Host "Setup complete. Ensure you do NOT commit .env. Use GitHub secrets for CI or Ansible templating for production deployments." 

# Copy .env to VM (optional) — prompt user
$copyToVM = Read-Host "Do you want to copy .env to the VM and restart Docker Compose? (Y/N)"
if ($copyToVM -match '^[Yy]') {
  $VM_IP = TFOut 'app_public_ip'
  if (-not (Test-Path $PrivateKeyPath)) { Write-Host "Private key not found at $PrivateKeyPath. Provide path or set up Ansible."; exit }
  Write-Host "Copying .env to vm $VM_IP..."
  & scp -i $PrivateKeyPath "$(Join-Path $PSScriptRoot '..\backend\.env')" "$VMUser@$VM_IP:/home/$VMUser/shortifyaf/.env"
  Write-Host "Restarting docker compose on vm..."
  & ssh -i $PrivateKeyPath "$VMUser@$VM_IP" 'cd /opt/shortifyaf && docker compose pull && docker compose up -d'
  Write-Host "Copied .env and restarted compose on VM $VM_IP. Check logs to confirm." 
}

Write-Host "Finished."