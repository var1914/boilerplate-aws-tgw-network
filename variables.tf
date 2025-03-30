# Global Configuration Variables
variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
# VPC Configuration Variables
variable "vpcs" {
  description = "Configuration for all VPCs to be created"
  type = map(object({
    cidr_block           = string
    name                 = string
    availability_zones   = list(string)
    public_subnets       = list(string)
    private_subnets      = list(string)
    database_subnets     = list(string)
    enable_nat_gateway   = bool
    single_nat_gateway   = bool
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    enable_vpn_gateway   = bool
    enable_igw           = optional(bool, false)  # Only true for the egress VPC
    requires_internet    = optional(bool, true)   # Does this VPC need internet access?
    tags                 = map(string)
  }))
}

# Centralized Egress Configuration
variable "centralized_egress" {
  description = "Configuration for centralized egress"
  type = object({
    enabled             = bool
    egress_vpc_key      = string  # Key of the VPC to use as egress point
    create_igw_routes   = bool    # Whether to create default routes to IGW for other VPCs
  })
  default = {
    enabled           = true
    egress_vpc_key    = "management"
    create_igw_routes = true
  }
}

# Transit Gateway Configuration
variable "transit_gateway_config" {
  description = "Configuration for the Transit Gateway"
  type = object({
    name                                  = string
    description                           = string
    amazon_side_asn                       = number
    auto_accept_shared_attachments        = string
    default_route_table_association       = string
    default_route_table_propagation       = string
    vpn_ecmp_support                      = string
    dns_support                           = string
    transit_gateway_cidr_blocks           = list(string)
    tags                                  = map(string)
  })
  default = {
    name                                  = "main-transit-gateway"
    description                           = "Main Transit Gateway for VPC connections"
    amazon_side_asn                       = 64512
    auto_accept_shared_attachments        = "enable"
    default_route_table_association       = "enable"
    default_route_table_propagation       = "enable"
    vpn_ecmp_support                      = "enable"
    dns_support                           = "enable"
    transit_gateway_cidr_blocks           = []
    tags                                  = {}
  }
}

# Transit Gateway Route Tables
variable "tgw_route_tables" {
  description = "Route tables to create for the Transit Gateway"
  type = map(object({
    name = string
    tags = map(string)
  }))
  default = {}
}

# Transit Gateway Attachments
variable "tgw_vpc_attachments" {
  description = "Configuration for Transit Gateway VPC attachments"
  type = map(object({
    vpc_id                                   = string
    subnet_ids                               = list(string)
    dns_support                              = string
    ipv6_support                             = string
    appliance_mode_support                   = string
    transit_gateway_default_route_table_association = bool
    transit_gateway_default_route_table_propagation = bool
    transit_gateway_route_table_id           = string
    tags                                     = map(string)
  }))
  default = {}
}

# On-Premises Connectivity
variable "on_premises_connectivity" {
  description = "Configuration for on-premises connectivity"
  type = object({
    enable_direct_connect     = bool
    enable_vpn                = bool
    customer_gateway_ip       = string
    customer_gateway_asn      = number
    vpn_connection_type       = string
    static_routes_only        = bool
    static_routes_destinations = list(string)
    tags                      = map(string)
  })
  default = {
    enable_direct_connect     = false
    enable_vpn                = false
    customer_gateway_ip       = ""
    customer_gateway_asn      = 65000
    vpn_connection_type       = "ipsec.1"
    static_routes_only        = true
    static_routes_destinations = []
    tags                      = {}
  }
}

# Security Configuration
variable "security_config" {
  description = "Security configuration for network resources"
  type = object({
    enable_flow_logs          = bool
    flow_logs_retention       = number
    enable_transit_gateway_network_manager = bool
    nacl_rules                = map(any)
    enable_network_firewall   = bool
  })
  default = {
    enable_flow_logs          = true
    flow_logs_retention       = 7
    enable_transit_gateway_network_manager = false
    nacl_rules                = {}
    enable_network_firewall   = false
  }
}