# Terraform Configuration for ShortifyAF

This directory contains the Terraform configuration to provision the cloud infrastructure for the ShortifyAF URL shortener application on AWS. The configuration has been refactored into focused modules so it matches the project rubric and is easier to maintain.

## Architecture

The infrastructure includes:

- **VPC**: Private network with public and private subnets
- **EC2 Instances**:
  - Application server in private subnet
  - Bastion host in public subnet for SSH access
- **Database**: MongoDB Atlas (external, free tier available)
- **ECR**: Private container registry for Docker images
- **ALB**: Application Load Balancer for web traffic
- **Security Groups**: Proper network security rules
The configuration is split into reusable modules under `./modules`:

- `modules/vpc` — VPC, public & private subnets, NAT gateways, routing
- `modules/compute` — EC2 (bastion + app) and their security groups
- `modules/alb` — ALB, listeners, target groups and security rules
- `modules/ecr` — ECR repositories for frontend/backend images

Note: a `modules/docdb` module exists in the tree for reference, but it is not invoked by the root configuration — this project uses MongoDB Atlas by default.

Temporary public access: while there's an account restriction preventing ALB creation in this AWS account, the configuration can temporarily place the app instance in a public subnet with a public IP so the frontend and API are reachable directly. This is controlled by `modules/compute` variable `make_app_public` and is intentionally a short-lived, reversible change — it is not recommended for long-term production usage. See the module documentation and root `main.tf` for toggling this feature.

## Prerequisites

1. **AWS Account**: You need an AWS account with appropriate permissions
2. **Terraform**: Install Terraform CLI (version >= 1.2.0)
3. **AWS CLI**: Configure AWS credentials
4. **SSH Key Pair**: Create an SSH key pair in AWS

## Setup Instructions

### 1. Configure AWS Credentials

You have several options to provide AWS credentials:

#### Option A: AWS CLI Configuration (Recommended)
```bash
aws configure
```
Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (json)

#### Option B: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Option C: AWS Profile
```bash
aws configure --profile shortifyaf
export AWS_PROFILE=shortifyaf
```

### 2. Create SSH Key Pair

Create an SSH key pair in AWS EC2 console or via CLI:

```bash
aws ec2 create-key-pair --key-name shortifyaf-key --query 'KeyMaterial' --output text > shortifyaf-key.pem
chmod 400 shortifyaf-key.pem
```

### 3. Configure Variables

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update the values that apply to your environment:
- `allowed_ssh_cidr`: Replace with your IP address (e.g., "203.0.113.1/32")
- `key_name`: the EC2 keypair name you'll use for bastion/app SSH
- `instance_type` and `bastion_instance_type` if you need different instance sizes

Important: This project uses an external MongoDB (MongoDB Atlas) for production. The Terraform deployment expects you to supply a MongoDB Atlas connection string (MONGODB_ATLAS_URI) to the application when deploying images to EC2. You do not need to run MongoDB on the EC2 instance in production unless you explicitly want to. The previously-added DocumentDB module has been removed from the root configuration to avoid provisioning paid resources unintentionally.

### 4. Initialize Terraform

```bash
terraform init
```

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
ssh -i shortifyaf-key.pem ec2-user@<bastion-public-ip>
```

3. From bastion, SSH to app server:
```bash
ssh -i shortifyaf-key.pem ec2-user@<app-private-ip>
```

### Application Access

The application will be accessible via the ALB DNS name:
```bash
terraform output alb_dns_name
```

## Deploying the Application

### Build and Push Docker Images

1. Get ECR repository URLs:
```bash
BACKEND_REPO=$(terraform output -raw ecr_backend_repository_url)
FRONTEND_REPO=$(terraform output -raw ecr_frontend_repository_url)
```

2. Authenticate Docker with ECR:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
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

### Deploy on EC2 Instance

SSH to the app server via bastion and run the deployment steps. In production we expect the app to use a hosted MongoDB Atlas connection string and for the ALB to terminate and route traffic to the `frontend` (port 80) and `backend` (port 3001). Below is a simplified production `docker-compose.yml` sample that uses the Atlas connection string and sets the correct environment variables.

```bash
# Get outputs
ALB_DNS=$(terraform output -raw alb_dns_name)
BACKEND_REPO=$(terraform output -raw ecr_backend_repository_url)
FRONTEND_REPO=$(terraform output -raw ecr_frontend_repository_url)

# Note: Set MONGODB_ATLAS_URI in the EC2 environment (do not commit secrets):
# export MONGODB_ATLAS_URI='mongodb+srv://<user>:<password>@cluster0.../shortifyaf?retryWrites=true&w=majority'

cat > docker-compose.yml << EOF
version: '3.8'
services:
  backend:
    image: $BACKEND_REPO:latest
    container_name: shortifyaf-backend
    restart: unless-stopped
    environment:
      PORT: 3001
      MONGODB_URI: "${MONGODB_ATLAS_URI}"
      FRONTEND_URL: http://$ALB_DNS
    ports:
      - "3001:3001"

  frontend:
    image: $FRONTEND_REPO:latest
    container_name: shortifyaf-frontend
    restart: unless-stopped
    # The frontend was built with a default production base of /api, but you may override with VITE_API_URL
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

This configuration uses mostly free tier eligible resources where possible:

- t3.micro EC2 instances (free for 750 hours/month for 12 months)
- ALB, NAT Gateway, and data transfer may incur costs

Note: DocumentDB is intentionally not provisioned by default — if you choose to enable it the service is not free and will incur AWS charges.

Monitor your AWS billing dashboard for actual costs.

## Security Notes

- The bastion host is in a public subnet and accepts SSH from anywhere (configurable)
- The app server is in a private subnet, only accessible via bastion
- Database is in private subnet, only accessible from app server
- Consider using AWS Systems Manager Session Manager for SSH access instead of bastion host
- Enable CloudTrail and Config for auditing
- Use AWS KMS for encryption at rest