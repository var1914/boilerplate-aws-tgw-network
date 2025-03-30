variable "egress_vpc_id" {
  description = "ID of the VPC used for centralized egress"
  type        = string
}

variable "egress_vpc_attachment_id" {
  description = "ID of the Transit Gateway attachment for the egress VPC"
  type        = string
}

variable "egress_vpc_igw_id" {
  description = "ID of the Internet Gateway in the egress VPC"
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table to add the default route to"
  type        = string
}

variable "egress_vpc_public_route_table_ids" {
  description = "IDs of public route tables in the egress VPC"
  type        = list(string)
}

variable "egress_vpc_public_subnet_ids" {
  description = "IDs of public subnets in the egress VPC"
  type        = list(string)
}

variable "create_nacl" {
  description = "Whether to create a Network ACL to control egress traffic"
  type        = bool
  default     = false
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways in the egress VPC"
  type        = bool
  default     = false
}

variable "use_nat_instances" {
  description = "Whether to use NAT instances instead of NAT Gateways"
  type        = bool
  default     = false
}

variable "vpc_cidr_blocks" {
  description = "List of CIDR blocks for all VPCs in the network"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}