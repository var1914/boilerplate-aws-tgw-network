# VPC Module
# Creates a VPC with public, private, and database subnets across multiple AZs

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = var.vpc_name
  cidr = var.cidr_block

  azs                 = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  
  # NAT Gateway configuration
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  
  # DNS settings
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  # VPN Gateway (optional)
  enable_vpn_gateway   = var.enable_vpn_gateway
  
  # Create a dedicated route table for each subnet
  create_database_subnet_route_table = true
  
  # Public subnet configuration
  map_public_ip_on_launch = true
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name        = var.vpc_name
    }
  )
}