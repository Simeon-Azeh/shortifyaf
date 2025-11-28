# Terraform Configuration for ShortifyAF

This directory contains the Terraform configuration to provision the cloud infrastructure for the ShortifyAF URL shortener application on Azure. The configuration has been refactored into focused modules so it matches the project rubric and is easier to maintain.

## Architecture

The infrastructure includes:

- **Virtual Network (VNet)**: Private network with public and private subnets
- **Virtual Machines (VMs)**:
  - Application server in private subnet
  - Bastion host in public subnet for SSH access
- **Database**: Azure PostgreSQL Flexible Server (managed)
- **Azure Container Registry (ACR)**: Private container registry for Docker images
- **Load Balancer (LB)**: Azure Load Balancer for web traffic
- **Network Security Groups (NSGs)**: Proper network security rules

The configuration is split into reusable modules under `./modules`:

- `modules/vpc` — VNet, public & private subnets, routing
- `modules/compute` — VMs (bastion + app) and their NSGs
- `modules/postgres` — Azure PostgreSQL Flexible Server
- `modules/acregistry` — ACR repositories for frontend/backend images

Temporary public access: while there's an account restriction preventing ALB creation in this AWS account, the configuration can temporarily place the app instance in a public subnet with a public IP so the frontend and API are reachable directly. This is controlled by `modules/compute` variable `make_app_public` and is intentionally a short-lived, reversible change — it is not recommended for long-term production usage. See the module documentation and root `main.tf` for toggling this feature.

## Prerequisites

1. **Azure Account**: You need an Azure account with appropriate permissions
2. **Terraform**: Install Terraform CLI (version >= 1.2.0)
3. **Azure CLI**: Install and configure Azure CLI
4. **SSH Key Pair**: Create an SSH key pair

## Setup Instructions

## Setup Instructions

### 1. Configure Azure Credentials

You have several options to provide Azure credentials:

#### Option A: Azure CLI Configuration (Recommended)
```bash
az login
```

#### Option B: Service Principal
Create a Service Principal and set environment variables:
```bash
az ad sp create-for-rbac --name shortifyaf-sp --role Contributor --scopes /subscriptions/<subscription-id>
export ARM_CLIENT_ID="<app-id>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"

#### Required SSH key secret for CI/CD
If you will run Terraform from CI (GitHub Actions), make sure to add your SSH public key as a GitHub secret named `AZURE_SSH_PUBLIC_KEY` so the workflow can pass it to Terraform and provision VMs:

```bash
cat ~/.ssh/shortifyaf-key.pub | pbcopy  # macOS
cat ~/.ssh/shortifyaf-key.pub | clip    # Windows PowerShell
# then add it to GitHub repo secrets as AZURE_SSH_PUBLIC_KEY
```
```

### 2. Create SSH Key Pair

Create an SSH key pair:

```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/shortifyaf-key
```

### 3. Configure Variables

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update the values that apply to your environment:
- `allowed_ssh_cidr`: Replace with your IP address (e.g., "203.0.113.1/32")
- `vm_size` and `bastion_vm_size` if you need different VM sizes

Important: This project uses Azure PostgreSQL Flexible Server for production. The Terraform deployment provisions the database and provides the connection string.

### 4. Initialize Terraform

```bash
terraform init
```
If you intend to use continuous deployment from GitHub Actions, configure a remote backend (e.g., Azure Storage) so the CI runner can access the Terraform state. Without a remote backend the GitHub workflow will not have access to the local state and `terraform output` will return "No outputs found".

Example backend (Azure Storage) config in `terraform/backend.tf`:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate<unique>"
    container_name       = "tfstate"
    key                  = "shortifyaf.tfstate"
  }
}
```
You must create the storage account and container before initializing with this backend. See Azure docs for guidance.

### 5. Plan the Deployment

```bash
terraform plan
```

Review the plan to ensure it matches your expectations.

### 6. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Accessing Your Infrastructure

### SSH Access via Bastion Host

1. Get the bastion host public IP:
```bash
terraform output bastion_public_ip
```

2. SSH to bastion host:
```bash
ssh -i ~/.ssh/shortifyaf-key azureuser@<bastion-public-ip>
```

3. From bastion, SSH to app server:
```bash
ssh -i ~/.ssh/shortifyaf-key azureuser@<app-private-ip>
```

### Application Access

The application will be accessible via the Load Balancer public IP:
```bash
terraform output lb_public_ip
```

## Deploying the Application

### Build and Push Docker Images

1. Get ACR repository URLs:
```bash
BACKEND_REPO=$(terraform output -raw acr_backend_repository_url)
FRONTEND_REPO=$(terraform output -raw acr_frontend_repository_url)
```

2. Authenticate Docker with ACR:
```bash
az acr login --name <acr-name>
```

3. Build and push backend image:
```bash
cd ../backend
docker build -t shortifyaf-backend .
docker tag shortifyaf-backend:latest $BACKEND_REPO:latest
docker push $BACKEND_REPO:latest
```

4. Build and push frontend image:
```bash
cd ../frontend
docker build -t shortifyaf-frontend .
docker tag shortifyaf-frontend:latest $FRONTEND_REPO:latest
docker push $FRONTEND_REPO:latest
```

### Deploy on VM Instance

SSH to the app server via bastion and run the deployment steps. In production we expect the app to use the provisioned Azure PostgreSQL and for the LB to terminate and route traffic to the `frontend` (port 80) and `backend` (port 3001). Below is a simplified production `docker-compose.yml` sample.

```bash
# Get outputs
LB_IP=$(terraform output -raw lb_public_ip)
BACKEND_REPO=$(terraform output -raw acr_backend_repository_url)
FRONTEND_REPO=$(terraform output -raw acr_frontend_repository_url)
DB_URL=$(terraform output -raw postgres_connection_string)

cat > docker-compose.yml << EOF
version: '3.8'
services:
  backend:
    image: $BACKEND_REPO:latest
    container_name: shortifyaf-backend
    restart: unless-stopped
    environment:
      PORT: 3001
      DATABASE_URL: "$DB_URL"
      FRONTEND_URL: http://$LB_IP
    ports:
      - "3001:3001"

  frontend:
    image: $FRONTEND_REPO:latest
    container_name: shortifyaf-frontend
    restart: unless-stopped
    environment:
      VITE_API_URL: /api
    depends_on:
      - backend
    ports:
      - "80:80"

EOF

# Run the application
docker-compose up -d
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Cost Estimation

This configuration uses cost-effective Azure resources:

- B1s VMs (low-cost burstable instances)
- Azure PostgreSQL Flexible Server (pay-as-you-go)
- Load Balancer (minimal cost for basic LB)

Monitor your Azure cost management dashboard for actual costs.

## Security Notes

- The bastion host is in a public subnet and accepts SSH from configured CIDR
- The app server is in a private subnet, only accessible via bastion
- Database has private networking, only accessible from app server
- Consider using Azure Bastion for secure SSH access
- Enable Azure Monitor and Log Analytics for auditing
- Use Azure Key Vault for secrets management