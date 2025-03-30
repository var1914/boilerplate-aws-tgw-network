output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = aws_route_table.database[*].id
}

output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.this[0].id : null
}

output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_vpc.this.default_security_group_id
}

output "has_internet_gateway" {
  description = "Whether this VPC has an Internet Gateway"
  value       = length(aws_internet_gateway.this) > 0
}