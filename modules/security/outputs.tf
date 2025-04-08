variable "vpcs" {
  description = "Map of VPC names to VPC IDs for flow logs"
  type        = map(string)
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 14
}

variable "enable_transit_gateway_network_manager" {
  description = "Whether to enable Network Manager for the Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "nacl_rules" {
  description = "Map of Network ACL rules to create"
  type        = map(any)
  default     = {}
}

variable "enable_network_firewall" {
  description = "Whether to enable AWS Network Firewall"
  type        = bool
  default     = false
}

variable "egress_vpc_id" {
  description = "ID of the Egress VPC for Network Firewall deployment"
  type        = string
  default     = ""
}

variable "firewall_subnet_ids" {
  description = "List of subnet IDs for Network Firewall deployment"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}