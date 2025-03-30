output "transit_gateway_id" {
  description = "ID of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "ARN of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_owner_id" {
  description = "AWS account ID that owns the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.owner_id
}

output "route_table_ids" {
  description = "Map of Transit Gateway route table IDs keyed by name"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "default_route_table_id" {
  description = "ID of the default Transit Gateway route table"
  value       = data.aws_ec2_transit_gateway_route_table.default.id
}

output "global_network_id" {
  description = "ID of the Network Manager Global Network (if enabled)"
  value       = var.enable_network_manager ? aws_networkmanager_global_network.this[0].id : null
}

output "association_default_route_table_id" {
  description = "ID of the default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "ID of the default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}