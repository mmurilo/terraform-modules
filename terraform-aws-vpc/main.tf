locals {
  name        = var.vpc_name
  region      = coalesce(var.vpc_region, data.aws_region.current.region)
  vpc_cidr    = var.vpc_cidr
  azs         = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  vpc_this_id = try(module.vpc.vpc_id, null)
  tags        = var.tags

  # Extract the base VPC CIDR mask from the provided CIDR
  vpc_cidr_mask = tonumber(split("/", local.vpc_cidr)[1])

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

  # Find the largest (most granular) subnet mask to use as our base unit for calculations
  largest_subnet_mask = max(
    var.private_subnet_cidr_mask,
    var.database_subnet_cidr_mask,
    var.public_subnet_cidr_mask,
    var.intra_subnet_cidr_mask
  )

  # Calculate how many base units each subnet type consumes
  private_units_per_subnet  = pow(2, local.largest_subnet_mask - var.private_subnet_cidr_mask)
  database_units_per_subnet = pow(2, local.largest_subnet_mask - var.database_subnet_cidr_mask)
  public_units_per_subnet   = pow(2, local.largest_subnet_mask - var.public_subnet_cidr_mask)
  intra_units_per_subnet    = pow(2, local.largest_subnet_mask - var.intra_subnet_cidr_mask)

  # Calculate total units needed for each subnet type
  private_total_units  = length(local.azs) * local.private_units_per_subnet
  database_total_units = length(local.azs) * local.database_units_per_subnet
  public_total_units   = length(local.azs) * local.public_units_per_subnet
  intra_total_units    = length(local.azs) * local.intra_units_per_subnet

  # Calculate starting indices (in base units)
  private_start_unit  = 0
  public_start_unit   = local.private_start_unit + local.private_total_units
  database_start_unit = local.public_start_unit + local.public_total_units
  intra_start_unit    = local.database_start_unit + local.database_total_units

  # Calculate subnet CIDRs dynamically - now with non-overlapping ranges
  private_subnets = coalesce(var.private_subnets, [
    for k, v in local.azs : cidrsubnet(
      local.vpc_cidr,
      local.private_newbits,
      (local.private_start_unit / local.private_units_per_subnet) + k
    )
  ])

  public_subnets = coalesce(var.public_subnets, [
    for k, v in local.azs : cidrsubnet(
      local.vpc_cidr,
      local.public_newbits,
      (local.public_start_unit / local.public_units_per_subnet) + k
    )
  ])

  database_subnets = coalesce(var.database_subnets, [
    for k, v in local.azs : cidrsubnet(
      local.vpc_cidr,
      local.database_newbits,
      (local.database_start_unit / local.database_units_per_subnet) + k
    )
  ])

  intra_subnets = coalesce(var.intra_subnets, [
    for k, v in local.azs : cidrsubnet(
      local.vpc_cidr,
      local.intra_newbits,
      (local.intra_start_unit / local.intra_units_per_subnet) + k
    )
  ])
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

module "vpc" {
  # source = "./modules/terraform-aws-vpc"
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  # subnets
  private_subnets     = local.private_subnets
  database_subnets    = var.create_database_subnets ? local.database_subnets : []
  public_subnets      = var.create_public_subnets ? local.public_subnets : []
  intra_subnets       = var.create_intra_subnets ? local.intra_subnets : []
  intra_subnet_suffix = "tgw"


  create_database_subnet_group           = var.create_database_subnet_group
  create_database_subnet_route_table     = var.create_database_subnet_route_table
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  database_subnet_group_name             = "${local.name}-dbsubnetgroup"
  manage_default_network_acl             = var.manage_default_network_acl
  manage_default_route_table             = var.manage_default_route_table
  manage_default_security_group          = var.manage_default_security_group
  map_public_ip_on_launch                = var.map_public_ip_on_launch
  enable_dns_hostnames                   = var.enable_dns_hostnames
  enable_dns_support                     = var.enable_dns_support
  enable_nat_gateway                     = var.enable_nat_gateway
  single_nat_gateway                     = var.single_nat_gateway
  one_nat_gateway_per_az                 = var.one_nat_gateway_per_az

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
