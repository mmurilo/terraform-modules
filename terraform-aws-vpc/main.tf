# filepath: /Users/mmurilo/Documents/projects/github/terraform-modules/terraform-aws-vpc/main.tf
locals {
  name             = var.vpc_name
  region           = coalesce(var.vpc_region, data.aws_region.current.name)
  vpc_cidr         = var.vpc_cidr
  azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  vpc_this_id      = try(module.vpc.vpc_id, null)
  tags             = var.tags
  
  # Extract the base VPC CIDR mask from the provided CIDR
  vpc_cidr_mask    = tonumber(split("/", local.vpc_cidr)[1])
  
  # Validate subnet masks are larger than VPC CIDR mask to ensure subnets are smaller than VPC
  validate_private_mask  = var.private_subnet_cidr_mask > local.vpc_cidr_mask ? true : tobool("Private subnet mask (${var.private_subnet_cidr_mask}) must be larger than VPC CIDR mask (${local.vpc_cidr_mask})")
  validate_database_mask = var.database_subnet_cidr_mask > local.vpc_cidr_mask ? true : tobool("Database subnet mask (${var.database_subnet_cidr_mask}) must be larger than VPC CIDR mask (${local.vpc_cidr_mask})")
  validate_public_mask   = var.public_subnet_cidr_mask > local.vpc_cidr_mask ? true : tobool("Public subnet mask (${var.public_subnet_cidr_mask}) must be larger than VPC CIDR mask (${local.vpc_cidr_mask})")
  validate_intra_mask    = var.intra_subnet_cidr_mask > local.vpc_cidr_mask ? true : tobool("Intra subnet mask (${var.intra_subnet_cidr_mask}) must be larger than VPC CIDR mask (${local.vpc_cidr_mask})")
  
  # Calculate subnet newbits (the difference between subnet mask and VPC mask)
  private_newbits  = var.private_subnet_cidr_mask - local.vpc_cidr_mask
  database_newbits = var.database_subnet_cidr_mask - local.vpc_cidr_mask
  public_newbits   = var.public_subnet_cidr_mask - local.vpc_cidr_mask
  intra_newbits    = var.intra_subnet_cidr_mask - local.vpc_cidr_mask
  
  # Calculate subnet CIDRs dynamically based on the VPC CIDR and specified subnet masks
  private_subnets  = coalesce(var.private_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.private_newbits, k)])
  database_subnets = coalesce(var.database_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.database_newbits, k + length(local.azs) * 3)])
  public_subnets   = coalesce(var.public_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.public_newbits, k + length(local.azs))])
  intra_subnets    = coalesce(var.intra_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.intra_newbits, k + length(local.azs) * 2)])
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

module "vpc" {
  # source = "./modules/terraform-aws-vpc"
  source = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  # subnets
  private_subnets     = local.private_subnets
  database_subnets    = var.create_database_subnets ? local.database_subnets : []
  public_subnets      = var.create_public_subnets ? local.public_subnets : []
  intra_subnets       = var.create_intra_subnets ? local.intra_subnets : []
  intra_subnet_suffix = "tgw"


  create_database_subnet_group  = var.create_database_subnet_group
  database_subnet_group_name    = "${local.name}-dbsubnetgroup"
  manage_default_network_acl    = var.manage_default_network_acl
  manage_default_route_table    = var.manage_default_route_table
  manage_default_security_group = var.manage_default_security_group
  map_public_ip_on_launch       = var.map_public_ip_on_launch
  enable_dns_hostnames          = var.enable_dns_hostnames
  enable_dns_support            = var.enable_dns_support
  enable_nat_gateway            = var.enable_nat_gateway
  single_nat_gateway            = var.single_nat_gateway
  one_nat_gateway_per_az        = var.one_nat_gateway_per_az

  # vpn
  enable_vpn_gateway                 = var.enable_vpn_gateway
  vpn_gateway_id                     = var.vpn_gateway_id
  amazon_side_asn                    = var.amazon_side_asn
  vpn_gateway_az                     = var.vpn_gateway_az
  propagate_intra_route_tables_vgw   = var.propagate_intra_route_tables_vgw
  propagate_private_route_tables_vgw = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw  = var.propagate_public_route_tables_vgw
  vpn_gateway_tags                   = var.vpn_gateway_tags

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.enable_flow_log
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval
  flow_log_traffic_type                = var.flow_log_traffic_type
  flow_log_destination_type            = var.flow_log_destination_type
  flow_log_destination_arn             = var.enable_flow_log ? try(var.flow_log_bucket_arn, null) : null

  tags = local.tags
  public_subnet_tags = var.for_eks ? {
    "kubernetes.io/role/elb" = 1
  } : null
  private_subnet_tags = var.for_eks ? {
    "kubernetes.io/role/internal-elb" = 1
  } : null
}
