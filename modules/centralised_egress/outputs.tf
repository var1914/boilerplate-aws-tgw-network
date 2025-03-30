output "default_route_id" {
  description = "ID of the default route in the Transit Gateway"
  value       = aws_ec2_transit_gateway_route.default_internet_route.id
}

output "egress_routes" {
  description = "IDs of routes in the egress VPC to the Internet Gateway"
  value       = aws_route.egress_to_igw[*].id
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways created (if any)"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways created (if any)"
  value       = aws_eip.nat[*].public_ip
}

output "network_acl_id" {
  description = "ID of the Network ACL created (if any)"
  value       = var.create_nacl ? aws_network_acl.egress_control[0].id : null
}

output "security_group_id" {
  description = "ID of the security group created for NAT instances (if any)"
  value       = var.use_nat_instances ? aws_security_group.nat[0].id : null
}