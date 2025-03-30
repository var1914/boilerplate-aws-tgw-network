output "tgw_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "vpc_id" {
  description = "ID of the attached VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs used for the attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.subnet_ids
}

output "association_route_table_id" {
  description = "ID of the associated Transit Gateway route table"
  value       = var.route_table_id
}

output "propagation_route_table_ids" {
  description = "IDs of the Transit Gateway route tables that this attachment propagates to"
  value       = var.propagate_to_route_tables
}

output "vpc_routes_added" {
  description = "VPC route table IDs that have routes to the Transit Gateway"
  value       = var.vpc_route_table_ids
}