output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}
output "private_subnets" {
  description = "Private Subnets"
  value       = module.vpc.private_subnets
}
output "private_subnets_cidr" {
  description = "Private Subnets CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}
output "public_subnets" {
  description = "Public Subnets"
  value       = module.vpc.public_subnets
}
output "public_subnets_cidr" {
  description = "Public Subnets CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}
output "data_subnets" {
  description = "Database Subnets"
  value       = module.vpc.database_subnets
}
output "data_subnets_cidr" {
  description = "Database Subnets CIDR"
  value       = module.vpc.database_subnets_cidr_blocks
}
output "tgw_subnets" {
  description = "TGW Subnets"
  value       = module.vpc.intra_subnets
}
output "tgw_subnets_cidr" {
  description = "TGW Subnets CIDR"
  value       = module.vpc.intra_subnets_cidr_blocks
}
output "nat_public_ips" {
  description = "NAT Public IPs"
  value       = module.vpc.nat_public_ips
}
output "vpc" {
  description = "outputs from VPC upstream module"
  value       = try(module.vpc, null)
}
output "vpce" {
  description = "outputs from VPCE upstream module"
  value       = try(module.vpc_endpoints[0], null)
}

output "vpc_private_route_table_ids" {
  description = "outputs from VPCE upstream module"
  value       = try(module.vpc.private_route_table_ids, null)
}
