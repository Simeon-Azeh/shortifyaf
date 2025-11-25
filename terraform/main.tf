module "vnet" {
  source       = "./modules/azure_vnet"
  project_name = var.project_name
  environment  = var.environment
  location     = var.azure_location
  resource_group_name = local.effective_resource_group
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Optionally create the resource group if requested. If user prefers, they can create RG outside and keep create_resource_group=false
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.azure_location
}

# Choose which resource group to pass to modules: either the created one or the existing by name
locals {
  effective_resource_group = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
}
## VPC resources moved into modules/vpc
## (original aws_vpc/aws_subnet/aws_route_* resources removed)
module "acr" {
  source       = "./modules/azure_acr"
  project_name = var.project_name
  environment  = var.environment
  location     = var.azure_location
  resource_group_name = local.effective_resource_group
}

# Pass resource_group name to modules

module "compute" {
  source               = "./modules/azure_compute"
  project_name         = var.project_name
  environment          = var.environment
  vm_size              = var.vm_size
  bastion_vm_size      = var.bastion_vm_size
  admin_ssh_public_key = var.admin_ssh_public_key
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  resource_group_name  = local.effective_resource_group
  public_subnet_ids    = module.vnet.public_subnet_ids
  private_subnet_ids   = module.vnet.private_subnet_ids
  public_subnet_cidrs  = var.public_subnet_cidrs
  make_app_public      = true
}

/* For now, ALB/NLB on AWS are not required — with Azure we'll front via NSG and bastion or later add an Application Gateway if desired. */

module "postgres" {
  source       = "./modules/azure_postgres"
  project_name = var.project_name
  environment  = var.environment
  location     = var.azure_location
  resource_group_name = local.effective_resource_group
}

/* API listener & target-group are handled within modules/alb */

/* DocumentDB support removed — this configuration uses MongoDB Atlas (external) */