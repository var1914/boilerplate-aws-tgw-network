variable "name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Transit Gateway"
}

variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session"
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = string
  default     = "disable"
  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "Valid values for auto_accept_shared_attachments are 'enable' or 'disable'."
  }
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table"
  type        = string
  default     = "enable"
  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "Valid values for default_route_table_association are 'enable' or 'disable'."
  }
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table"
  type        = string
  default     = "enable"
  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "Valid values for default_route_table_propagation are 'enable' or 'disable'."
  }
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled"
  type        = string
  default     = "enable"
  validation {
    condition     = contains(["enable", "disable"], var.vpn_ecmp_support)
    error_message = "Valid values for vpn_ecmp_support are 'enable' or 'disable'."
  }
}

variable "dns_support" {
  description = "Whether DNS support is enabled"
  type        = string
  default     = "enable"
  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "Valid values for dns_support are 'enable' or 'disable'."
  }
}

variable "transit_gateway_cidr_blocks" {
  description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway"
  type        = list(string)
  default     = []
}

variable "route_tables" {
  description = "Map of route tables to create for the Transit Gateway"
  type = map(object({
    name = string
    tags = map(string)
  }))
  default = {}
}

variable "blackhole_routes" {
  description = "List of CIDR blocks to blackhole (prevent routing) in specific route tables"
  type = list(object({
    route_table_key = string
    cidr_block      = string
  }))
  default = []
}

variable "enable_network_manager" {
  description = "Whether to enable Network Manager for the Transit Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}