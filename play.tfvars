# Global Configuration
aws_region = "us-east-1"
tags = {
  Project     = "Enterprise Network"
  Owner       = "Network Team"
  Terraform   = "true"
}

# VPC Configuration
vpcs = {
  "production" = {
    cidr_block           = "10.0.0.0/16"
    name                 = "production"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets       = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    private_subnets      = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
    database_subnets     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
    enable_nat_gateway   = false # No NAT gateway needed since we'll use the transit gateway
    single_nat_gateway   = false 
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway   = false
    enable_igw           = false # No IGW needed for non-egress VPCs
    requires_internet    = true
    tags = {
      Type = "Production"
    }
  },
  "development" = {
    cidr_block           = "10.1.0.0/16"
    name                 = "development"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets       = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
    private_subnets      = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
    database_subnets     = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
    enable_nat_gateway   = false # No NAT gateway needed since we'll use the transit gateway
    single_nat_gateway   = false
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway   = false
    enable_igw           = false # No IGW needed for non-egress VPCs
    requires_internet    = true
    tags = {
      Type = "Development"
    }
  },
  "shared_services" = {
    cidr_block           = "10.2.0.0/16"
    name                 = "shared-services"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets       = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
    private_subnets      = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
    database_subnets     = ["10.2.20.0/24", "10.2.21.0/24", "10.2.22.0/24"]
    enable_nat_gateway   = false # No NAT gateway needed since we'll use the transit gateway
    single_nat_gateway   = false
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway   = false
    enable_igw           = false # No IGW needed for non-egress VPCs
    requires_internet    = true
    tags = {
      Type = "Shared Services"
    }
  },
  "data" = {
    cidr_block           = "10.3.0.0/16"
    name                 = "data"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets       = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"]
    private_subnets      = ["10.3.10.0/24", "10.3.11.0/24", "10.3.12.0/24"]
    database_subnets     = ["10.3.20.0/24", "10.3.21.0/24", "10.3.22.0/24"]
    enable_nat_gateway   = false # No NAT gateway needed since we'll use the transit gateway
    single_nat_gateway   = false
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway   = false
    enable_igw           = false # No IGW needed for non-egress VPCs
    requires_internet    = true
    tags = {
      Type = "Data"
    }
  },
  "management" = {
    cidr_block           = "10.4.0.0/16"
    name                 = "management"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets       = ["10.4.0.0/24", "10.4.1.0/24", "10.4.2.0/24"]
    private_subnets      = ["10.4.10.0/24", "10.4.11.0/24", "10.4.12.0/24"]
    database_subnets     = ["10.4.20.0/24", "10.4.21.0/24", "10.4.22.0/24"]
    enable_nat_gateway   = true # NAT gateway needed for egress VPC
    single_nat_gateway   = false # Use multiple NAT gateways for high availability
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway   = false
    enable_igw           = true # This is our designated egress VPC with IGW
    requires_internet    = true
    tags = {
      Type = "Management"
    }
  }
}

# Security Configuration
security_config = {
  enable_flow_logs          = true
  flow_logs_retention       = 30
  enable_transit_gateway_network_manager = true
  nacl_rules                = {}
  enable_network_firewall   = false
}