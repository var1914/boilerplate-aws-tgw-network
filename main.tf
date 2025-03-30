# Main Terraform file that orchestrates the modules

# Create VPCs with selective IGW deployment
module "vpcs" {
  source   = "./modules/vpc"
  for_each = var.vpcs

  vpc_name             = each.value.name
  cidr_block           = each.value.cidr_block
  availability_zones   = each.value.availability_zones
  public_subnets       = each.value.public_subnets
  private_subnets      = each.value.private_subnets
  database_subnets     = each.value.database_subnets
  enable_nat_gateway   = each.value.enable_nat_gateway
  single_nat_gateway   = each.value.single_nat_gateway
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support
  
  # Only create IGW for the designated egress VPC if centralized egress is enabled
  enable_igw          = var.centralized_egress.enabled ? (each.key == var.centralized_egress.egress_vpc_key) : each.value.enable_igw
  enable_vpn_gateway  = each.value.enable_vpn_gateway
  
  tags        = merge(var.tags, each.value.tags)
}

# Create Transit Gateway
module "transit_gateway" {
  source = "./modules/transit_gateway"

  name                            = var.transit_gateway_config.name
  description                     = var.transit_gateway_config.description
  amazon_side_asn                 = var.transit_gateway_config.amazon_side_asn
  auto_accept_shared_attachments  = var.transit_gateway_config.auto_accept_shared_attachments
  default_route_table_association = var.transit_gateway_config.default_route_table_association
  default_route_table_propagation = var.transit_gateway_config.default_route_table_propagation
  vpn_ecmp_support                = var.transit_gateway_config.vpn_ecmp_support
  dns_support                     = var.transit_gateway_config.dns_support
  transit_gateway_cidr_blocks     = var.transit_gateway_config.transit_gateway_cidr_blocks
  
  route_tables = var.tgw_route_tables
  
  tags        = merge(var.tags, var.transit_gateway_config.tags)
}

# Create Transit Gateway Attachments
module "tgw_attachments" {
  source   = "./modules/transit_gateway_attachment"
  for_each = var.vpcs

  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = module.vpcs[each.key].vpc_id
  subnet_ids         = module.vpcs[each.key].private_subnet_ids
  
  # Default to attaching to the route table corresponding to the VPC type
  # If no matching route table exists, use the default
  route_table_id = lookup(
    module.transit_gateway.route_table_ids,
    each.key,
    lookup(
      module.transit_gateway.route_table_ids,
      "default",
      null
    )
  )
  
  # Determine propagation based on VPC type
  propagate_to_route_tables = local.route_table_propagations[each.key]
  
  # For VPCs that need internet access but don't have their own IGW
  # add a default route to the Transit Gateway for internet traffic
  vpc_route_table_ids = var.centralized_egress.enabled && each.key != var.centralized_egress.egress_vpc_key && lookup(each.value, "requires_internet", true) ? module.vpcs[each.key].private_route_table_ids : []
  
  destination_cidr_block = "0.0.0.0/0"
  
  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = "tgw-attachment-${each.value.name}"
    }
  )
}

# Centralized Internet Egress Configuration
# Add specific default route in the Transit Gateway to the egress VPC's attachment
resource "aws_ec2_transit_gateway_route" "internet_egress" {
  count = var.centralized_egress.enabled ? 1 : 0
  
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.tgw_attachments[var.centralized_egress.egress_vpc_key].tgw_attachment_id
  transit_gateway_route_table_id = module.transit_gateway.default_route_table_id
}
