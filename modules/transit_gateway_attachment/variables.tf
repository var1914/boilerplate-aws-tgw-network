variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach to"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to use for the attachment (must be in different AZs)"
  type        = list(string)
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

variable "ipv6_support" {
  description = "Whether IPv6 support is enabled"
  type        = string
  default     = "disable"
  validation {
    condition     = contains(["enable", "disable"], var.ipv6_support)
    error_message = "Valid values for ipv6_support are 'enable' or 'disable'."
  }
}

variable "appliance_mode_support" {
  description = "Whether appliance mode support is enabled (for stateful packet inspection)"
  type        = string
  default     = "disable"
  validation {
    condition     = contains(["enable", "disable"], var.appliance_mode_support)
    error_message = "Valid values for appliance_mode_support are 'enable' or 'disable'."
  }
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether to associate with the default route table"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether to propagate routes to the default route table"
  type        = bool
  default     = false
}

variable "route_table_id" {
  description = "ID of the Transit Gateway route table to associate with"
  type        = string
  default     = null
}

variable "propagate_to_route_tables" {
  description = "List of Transit Gateway route table IDs to propagate routes to"
  type        = list(string)
  default     = []
}

variable "vpc_route_table_ids" {
  description = "List of VPC route table IDs to add routes to the Transit Gateway"
  type        = list(string)
  default     = []
}

variable "destination_cidr_block" {
  description = "CIDR block for routing from VPC route tables to the Transit Gateway"
  type        = string
  default     = "0.0.0.0/0"  # Default to all traffic
}

variable "tags" {
  description = "Tags to apply to the Transit Gateway attachment"
  type        = map(string)
  default     = {}
}