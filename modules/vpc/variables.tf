variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources in"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnets" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Should a NAT Gateway be created?"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should only a single NAT Gateway be created?"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Should DNS hostnames be enabled for the VPC?"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should DNS support be enabled for the VPC?"
  type        = bool
  default     = true
}

variable "enable_igw" {
  description = "Should an Internet Gateway be created for the VPC?"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should a VPN Gateway be created in the VPC?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}