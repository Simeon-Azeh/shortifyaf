# Terraform Configuration for ShortifyAF

This directory contains the Terraform configuration to provision the cloud infrastructure for the ShortifyAF URL shortener application on AWS.

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

Edit `terraform.tfvars` and update:
- `allowed_ssh_cidr`: Replace with your IP address (e.g., "203.0.113.1/32")
- `db_master_password`: Set a strong password for DocumentDB
- Other variables as needed

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

SSH to the app server via bastion and run:

```bash
# Get outputs
DOCUMENTDB_ENDPOINT=$(terraform output -raw documentdb_endpoint)
ALB_DNS=$(terraform output -raw alb_dns_name)

# Create docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'
services:
  mongodb:
    image: mongo:7-jammy
    environment:
      MONGO_INITDB_DATABASE: shortifyaf
    volumes:
      - mongodb_data:/data/db
    networks:
      - shortifyaf-network

  backend:
    image: $BACKEND_REPO:latest
    environment:
      PORT: 3001
      MONGODB_URI: mongodb://$DOCUMENTDB_ENDPOINT:27017/shortifyaf
      FRONTEND_URL: http://$ALB_DNS
    depends_on:
      - mongodb
    networks:
      - shortifyaf-network
    ports:
      - "3001:3001"

  frontend:
    image: $FRONTEND_REPO:latest
    environment:
      VITE_API_URL: http://localhost:3001
    depends_on:
      - backend
    networks:
      - shortifyaf-network
    ports:
      - "80:80"

volumes:
  mongodb_data:

networks:
  shortifyaf-network:
    driver: bridge
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

This configuration uses mostly free tier eligible services:
- t3.micro EC2 instances (free for 750 hours/month for 12 months)
- DocumentDB (not free tier eligible)
- ALB, NAT Gateway, and data transfer will incur costs

Monitor your AWS billing dashboard for actual costs.

## Security Notes

- The bastion host is in a public subnet and accepts SSH from anywhere (configurable)
- The app server is in a private subnet, only accessible via bastion
- Database is in private subnet, only accessible from app server
- Consider using AWS Systems Manager Session Manager for SSH access instead of bastion host
- Enable CloudTrail and Config for auditing
- Use AWS KMS for encryption at rest