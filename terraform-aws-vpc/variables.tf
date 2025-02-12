variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}
variable "vpc_region" {
  description = "The AWS region where the VPC will be created"
  type        = string
  default     = null
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Must be a valid `/20` range."
  type        = string
  validation {
    condition     = cidrnetmask(var.vpc_cidr) == "255.255.240.0"
    error_message = "The VPC CIDR needs to be `/20`."
  }
}
variable "az_count" {
  description = "The number of Availability Zones to use"
  type        = number
  default     = 3

}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}
variable "flow_log_bucket_arn" {
  type    = string
  default = null
}
variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds"
  type        = number
  default     = 600
}
variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}
variable "flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs"
  type        = string
  default     = "s3"
}

# variable "vpc_subnets_map" {
#   type = map(any)
# }

variable "tags" {
  type    = map(string)
  default = null
}

variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  type        = bool
  default     = false
}
variable "manage_default_route_table" {
  description = "Should be true to manage default route table"
  type        = bool
  default     = false
}
variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = false
}
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks. Set `false` for pruduction"
  type        = bool
  default     = false
}
variable "one_nat_gateway_per_az" {
  description = "Should be true if you want to provision a NAT Gateway in each Availability Zone. Set `true` for pruduction"
  type        = bool
  default     = true
}
################################################################################
# VPN Gateway
################################################################################

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = bool
  default     = false
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  type        = string
  default     = ""
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN"
  type        = string
  default     = "64512"
}

variable "vpn_gateway_az" {
  description = "The Availability Zone for the VPN Gateway"
  type        = string
  default     = null
}

variable "propagate_intra_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  type        = map(string)
  default     = {}
}

################################################################################
# Subnets
################################################################################

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = null
}
variable "create_database_subnets" {
  description = "Controls if database subnets should be created"
  type        = bool
  default     = false
}
variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  type        = list(string)
  default     = null
}
variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)"
  type        = bool
  default     = false
}
variable "create_intra_subnets" {
  description = "Controls if intra subnets should be created"
  type        = bool
  default     = false
}
variable "intra_subnets" {
  description = "A list of intra subnets inside the VPC"
  type        = list(string)
  default     = null
}
variable "create_public_subnets" {
  description = "Controls if public subnets should be created"
  type        = bool
  default     = true
}
variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = null
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the public subnet should be assigned a public IP address"
  type        = bool
  default     = true
}

################################################################################
# VPC Endpoins
################################################################################

variable "create_vpce" {
  type    = bool
  default = true
}
variable "vpce_default_interfaces" {
  description = "A list of VPC Endpoints interfaces created by default"
  type        = list(string)
  default = [
    "ssm",
    "sts",
    "ssmmessages",
    "ec2",
    "ec2messages",
    "kms",
    "logs",
    "autoscaling",
    "elasticloadbalancing",
  ]
}
variable "vpce_extra_interfaces" {
  description = "A list of extra VPC Endpoints interfaces to be created"
  type        = list(string)
  default     = []
}

variable "vpce_default_gateways" {
  description = "A list of VPC Endpoints Gateways created by default"
  type        = list(string)
  default = [
    "s3"
  ]
}
variable "vpce_extra_gateways" {
  description = "A list of extra VPC Endpoints Gateways to be created"
  type        = list(string)
  default     = []
}
variable "for_eks" {
  description = "Set to true if the VPC is for EKS"
  type        = bool
  default     = false
}
