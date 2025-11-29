variable "azure_location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "spaincentral"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "shortifyaf"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "vm_size" {
  description = "Azure VM size for application server"
  type        = string
  default     = "Standard_B1s"
}

variable "bastion_vm_size" {
  description = "Azure VM size for bastion host"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_ssh_public_key" {
  description = "Public SSH key to inject for admin user on VMs (raw public key text). Provide the public key text or the path in tfvars."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into bastion (restrict to your IP for security)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "resource_group_name" {
  description = "Resource Group to use (if exists). If empty, Terraform creates one named shortifyaf-rg"
  type        = string
  default     = "shortifyaf-rg"
}

variable "create_resource_group" {
  description = "Whether to create the resource_group or treat resource_group_name as existing"
  type        = bool
  default     = false
}

/* Using MongoDB Atlas by default; DocumentDB option removed. */