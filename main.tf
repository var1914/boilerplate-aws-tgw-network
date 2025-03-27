# Main Terraform file that orchestrates the modules

# Create VPCs
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
  enable_vpn_gateway   = each.value.enable_vpn_gateway
  
  tags        = merge(var.tags, each.value.tags)
}