#!/bin/bash

# ShortifyAF Deployment Script
# This script helps deploy the application to the provisioned infrastructure

set -e

echo " Starting ShortifyAF deployment..."

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo " Terraform not initialized. Run 'terraform init' first."
    exit 1
fi

# Get outputs from Terraform
echo " Getting infrastructure details..."
BASTION_IP=$(terraform output -raw bastion_public_ip)
APP_IP=$(terraform output -raw app_private_ip)
BACKEND_REPO=$(terraform output -raw ecr_backend_repository_url)
FRONTEND_REPO=$(terraform output -raw ecr_frontend_repository_url)
ALB_DNS=$(terraform output -raw alb_dns_name)

echo "Bastion IP: $BASTION_IP"
echo "App Server IP: $APP_IP"
echo "ALB DNS: $ALB_DNS"

# Build and push Docker images
echo " Building and pushing Docker images..."

# Backend
echo "Building backend image..."
cd ../backend
docker build -t shortifyaf-backend .
docker tag shortifyaf-backend:latest $BACKEND_REPO:latest
echo "Pushing backend image..."
docker push $BACKEND_REPO:latest

# Frontend
echo "Building frontend image..."
cd ../frontend
docker build -t shortifyaf-frontend .
docker tag shortifyaf-frontend:latest $FRONTEND_REPO:latest
echo "Pushing frontend image..."
docker push $FRONTEND_REPO:latest

cd ../terraform

# Deploy to EC2 via bastion
echo " Deploying to EC2 instance..."

# Create deployment script
cat > deploy_app.sh << EOF
#!/bin/bash
set -e

echo "Updating system..."
sudo yum update -y

echo "Installing Docker and Docker Compose..."
sudo yum install -y docker awscli
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Logging into ECR..."
aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

echo "Creating docker-compose.yml..."
sudo tee docker-compose.yml > /dev/null << DOCKERCOMPOSE
version: '3.8'
services:
  backend:
    image: $BACKEND_REPO:latest
    container_name: shortifyaf-backend
    restart: unless-stopped
    environment:
      PORT: 3001
      MONGODB_URI: "\${MONGODB_ATLAS_URI}"
      FRONTEND_URL: http://$ALB_DNS
    ports:
      - "3001:3001"
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 3

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
DOCKERCOMPOSE

echo "Starting application..."
sudo docker-compose up -d

echo "Waiting for application to be healthy..."
sleep 30

echo "Checking application status..."
sudo docker-compose ps

echo " Deployment completed successfully!"
echo "Application should be accessible at: http://$ALB_DNS"
EOF

chmod +x deploy_app.sh

# Copy and execute deployment script via bastion
echo "Copying deployment script to bastion..."
scp -i ../shortifyaf-key.pem -o StrictHostKeyChecking=no deploy_app.sh ec2-user@$BASTION_IP:~

echo "Executing deployment on app server via bastion..."
ssh -i ../shortifyaf-key.pem -o StrictHostKeyChecking=no ec2-user@$BASTION_IP \
    "scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deploy_app.sh ec2-user@$APP_IP:~ && ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@$APP_IP 'chmod +x deploy_app.sh && ./deploy_app.sh'"

echo " Cleaning up temporary files..."
rm deploy_app.sh

echo " Deployment completed!"
echo " Application URL: http://$ALB_DNS"
echo ""
echo " Next steps:"
echo "1. Test the application at the URL above"
echo "2. Configure domain name and SSL certificate if needed"
echo "3. Set up monitoring and logging"
echo "4. Set MONGODB_ATLAS_URI environment variable with your MongoDB Atlas connection string"