terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region

  # Credentials will be provided via AWS CLI configuration or environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}