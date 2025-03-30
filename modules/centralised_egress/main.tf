# Centralized Egress Module
# This module configures egress routing through a designated VPC

# Create a default route in the Transit Gateway to direct internet traffic to the egress VPC
resource "aws_ec2_transit_gateway_route" "default_internet_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.egress_vpc_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# Create a route in the egress VPC's public route table to direct traffic to the IGW
resource "aws_route" "egress_to_igw" {
  count                  = length(var.egress_vpc_public_route_table_ids)
  route_table_id         = element(var.egress_vpc_public_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.egress_vpc_igw_id
}

# Optionally create network ACLs to control traffic
resource "aws_network_acl" "egress_control" {
  count      = var.create_nacl ? 1 : 0
  vpc_id     = var.egress_vpc_id
  subnet_ids = var.egress_vpc_public_subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "centralized-egress-nacl"
    }
  )
}

# Allow HTTP/HTTPS outbound traffic
resource "aws_network_acl_rule" "allow_http_outbound" {
  count          = var.create_nacl ? 1 : 0
  network_acl_id = aws_network_acl.egress_control[0].id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_https_outbound" {
  count          = var.create_nacl ? 1 : 0
  network_acl_id = aws_network_acl.egress_control[0].id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow return traffic
resource "aws_network_acl_rule" "allow_http_inbound" {
  count          = var.create_nacl ? 1 : 0
  network_acl_id = aws_network_acl.egress_control[0].id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Optionally create a NAT Gateway if one doesn't exist in the egress VPC
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? length(var.egress_vpc_public_subnet_ids) : 0
  
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "centralized-egress-nat-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? length(var.egress_vpc_public_subnet_ids) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(var.egress_vpc_public_subnet_ids, count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "centralized-egress-nat-${count.index + 1}"
    }
  )
  
  depends_on = [var.egress_vpc_igw_id]
}

# Create a security group for the NAT instances if using NAT instances instead of NAT Gateway
resource "aws_security_group" "nat" {
  count = var.use_nat_instances ? 1 : 0
  
  name        = "centralized-egress-nat-sg"
  description = "Security group for NAT instances"
  vpc_id      = var.egress_vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "centralized-egress-nat-sg"
    }
  )
}

resource "aws_security_group_rule" "nat_outbound" {
  count = var.use_nat_instances ? 1 : 0
  
  security_group_id = aws_security_group.nat[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nat_inbound" {
  count = var.use_nat_instances ? 1 : 0
  
  security_group_id = aws_security_group.nat[0].id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [for cidr in var.vpc_cidr_blocks : cidr]
}