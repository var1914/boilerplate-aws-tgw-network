output "flow_log_ids" {
  description = "IDs of the created VPC Flow Logs"
  value       = {
    for vpc_name, flow_log in aws_flow_log.vpc_flow_logs : vpc_name => flow_log.id
  }
}

output "flow_log_groups" {
  description = "CloudWatch Log Group names for the VPC Flow Logs"
  value       = {
    for vpc_name, log_group in aws_cloudwatch_log_group.flow_logs : vpc_name => log_group.name
  }
}

output "flow_logs_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_iam_role.flow_logs_role[0].arn : null
}

output "global_network_id" {
  description = "ID of the Network Manager Global Network"
  value       = var.enable_transit_gateway_network_manager ? aws_networkmanager_global_network.this[0].id : null
}

output "network_firewall_arn" {
  description = "ARN of the AWS Network Firewall"
  value       = var.enable_network_firewall && var.egress_vpc_id != "" ? aws_networkfirewall_firewall.this[0].arn : null
}

output "network_firewall_status" {
  description = "Current status of the AWS Network Firewall"
  value       = var.enable_network_firewall && var.egress_vpc_id != "" ? aws_networkfirewall_firewall.this[0].firewall_status : null
}

output "network_firewall_policy_arn" {
  description = "ARN of the AWS Network Firewall Policy"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall_policy.this[0].arn : null
}

output "network_acl_ids" {
  description = "IDs of the created Network ACLs"
  value       = {
    for name, nacl in aws_network_acl.custom : name => nacl.id
  }
}