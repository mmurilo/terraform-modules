# AWS VPC

This module creates a VPC with public and private subnets across multiple availability zones. It also creates a NAT Gateway in each availability zone for the private subnets.

## Usage

```hcl
module "vpc" {
  source                       =  "git@github.com:EverlongProject/aws-terraform-modules.git//terraform-aws-vpc?ref=aws-vpc-v5.9.0"
  vpc_name                     = var.vpc_name
  vpc_cidr                     = var.vpc_cidr
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/terraform-aws-vpc | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/terraform-aws-vpc/modules/vpc-endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.sg_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | The number of Availability Zones to use | `number` | `3` | no |
| <a name="input_create_database_subnet_group"></a> [create\_database\_subnet\_group](#input\_create\_database\_subnet\_group) | Controls if database subnet group should be created (n.b. database\_subnets must also be set) | `bool` | `false` | no |
| <a name="input_create_database_subnets"></a> [create\_database\_subnets](#input\_create\_database\_subnets) | Controls if database subnets should be created | `bool` | `false` | no |
| <a name="input_create_intra_subnets"></a> [create\_intra\_subnets](#input\_create\_intra\_subnets) | Controls if intra subnets should be created | `bool` | `false` | no |
| <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets) | Controls if public subnets should be created | `bool` | `true` | no |
| <a name="input_create_vpce"></a> [create\_vpce](#input\_create\_vpce) | n/a | `bool` | `true` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | A list of database subnets inside the VPC | `list(string)` | `null` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_flow_log_bucket_arn"></a> [flow\_log\_bucket\_arn](#input\_flow\_log\_bucket\_arn) | n/a | `string` | `null` | no |
| <a name="input_flow_log_destination_type"></a> [flow\_log\_destination\_type](#input\_flow\_log\_destination\_type) | Type of flow log destination. Can be s3 or cloud-watch-logs | `string` | `"s3"` | no |
| <a name="input_flow_log_max_aggregation_interval"></a> [flow\_log\_max\_aggregation\_interval](#input\_flow\_log\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds | `number` | `600` | no |
| <a name="input_flow_log_traffic_type"></a> [flow\_log\_traffic\_type](#input\_flow\_log\_traffic\_type) | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL | `string` | `"ALL"` | no |
| <a name="input_for_eks"></a> [for\_eks](#input\_for\_eks) | Set to true if the VPC is for EKS | `bool` | `false` | no |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnets inside the VPC | `list(string)` | `null` | no |
| <a name="input_manage_default_network_acl"></a> [manage\_default\_network\_acl](#input\_manage\_default\_network\_acl) | Should be true to adopt and manage Default Network ACL | `bool` | `false` | no |
| <a name="input_manage_default_route_table"></a> [manage\_default\_route\_table](#input\_manage\_default\_route\_table) | Should be true to manage default route table | `bool` | `false` | no |
| <a name="input_manage_default_security_group"></a> [manage\_default\_security\_group](#input\_manage\_default\_security\_group) | Should be true to adopt and manage default security group | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Specify true to indicate that instances launched into the public subnet should be assigned a public IP address | `bool` | `true` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Should be true if you want to provision a NAT Gateway in each Availability Zone. Set `true` for pruduction | `bool` | `true` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `null` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `null` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks. Set `false` for pruduction | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC. Must be a valid `/20` range. | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC | `string` | n/a | yes |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The AWS region where the VPC will be created | `string` | `null` | no |
| <a name="input_vpce_default_gateways"></a> [vpce\_default\_gateways](#input\_vpce\_default\_gateways) | A list of VPC Endpoints Gateways created by default | `list(string)` | <pre>[<br>  "s3"<br>]</pre> | no |
| <a name="input_vpce_default_interfaces"></a> [vpce\_default\_interfaces](#input\_vpce\_default\_interfaces) | A list of VPC Endpoints interfaces created by default | `list(string)` | <pre>[<br>  "ssm",<br>  "sts",<br>  "ssmmessages",<br>  "ec2",<br>  "ec2messages",<br>  "kms",<br>  "logs",<br>  "autoscaling",<br>  "elasticloadbalancing"<br>]</pre> | no |
| <a name="input_vpce_extra_gateways"></a> [vpce\_extra\_gateways](#input\_vpce\_extra\_gateways) | A list of extra VPC Endpoints Gateways to be created | `list(string)` | `[]` | no |
| <a name="input_vpce_extra_interfaces"></a> [vpce\_extra\_interfaces](#input\_vpce\_extra\_interfaces) | A list of extra VPC Endpoints interfaces to be created | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_subnets"></a> [data\_subnets](#output\_data\_subnets) | Database Subnets |
| <a name="output_data_subnets_cidr"></a> [data\_subnets\_cidr](#output\_data\_subnets\_cidr) | Database Subnets CIDR |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | NAT Public IPs |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | Private Subnets |
| <a name="output_private_subnets_cidr"></a> [private\_subnets\_cidr](#output\_private\_subnets\_cidr) | Private Subnets CIDR |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Public Subnets |
| <a name="output_public_subnets_cidr"></a> [public\_subnets\_cidr](#output\_public\_subnets\_cidr) | Public Subnets CIDR |
| <a name="output_tgw_subnets"></a> [tgw\_subnets](#output\_tgw\_subnets) | TGW Subnets |
| <a name="output_tgw_subnets_cidr"></a> [tgw\_subnets\_cidr](#output\_tgw\_subnets\_cidr) | TGW Subnets CIDR |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | outputs from VPC upstream module |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_private_route_table_ids"></a> [vpc\_private\_route\_table\_ids](#output\_vpc\_private\_route\_table\_ids) | outputs from VPCE upstream module |
| <a name="output_vpce"></a> [vpce](#output\_vpce) | outputs from VPCE upstream module |
<!-- END_TF_DOCS -->