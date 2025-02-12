locals {
  vpce_sg_name         = "${local.name}-vpcednpoint-sg"
  vpce_interfaces_list = concat(var.vpce_default_interfaces, compact(var.vpce_extra_interfaces))
  vpce_gateways_list   = concat(var.vpce_default_gateways, compact(var.vpce_extra_gateways))

  vpce_interfaces = { for i in local.vpce_interfaces_list : i => {
    service             = i
    private_dns_enabled = true
    subnet_ids          = try(module.vpc.private_subnets, null)
    security_group_ids  = [try(aws_security_group.sg_vpc_endpoints[0].id, null)]
    tags                = merge(local.tags, { Name = "${local.name}-${i}-vpcendpoint" })
    }
  }

  vpce_gateways = { for g in local.vpce_gateways_list : g => {
    service         = g
    service_type    = "Gateway"
    route_table_ids = module.vpc.private_route_table_ids
    tags            = merge(local.tags, { Name = "${local.name}-${g}-vpcendpoint" })
    }
  }
}

resource "aws_security_group" "sg_vpc_endpoints" {
  count       = var.create_vpce ? 1 : 0
  name        = local.vpce_sg_name
  description = "Security group for vpc endpoints"
  vpc_id      = local.vpc_this_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr]
  }

  tags = merge(local.tags, { Name = local.vpce_sg_name })

  lifecycle {
    create_before_destroy = true
  }
}
module "vpc_endpoints" {
  count  = var.create_vpce ? 1 : 0
  source = "./modules/terraform-aws-vpc/modules/vpc-endpoints"


  vpc_id             = local.vpc_this_id
  security_group_ids = [aws_security_group.sg_vpc_endpoints[0].id]
  endpoints          = merge(local.vpce_gateways, local.vpce_interfaces)
  tags               = local.tags
}
