# Transit Gateway Module
# Creates a Transit Gateway and associated route tables

# Create the Transit Gateway
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  vpn_ecmp_support                = var.vpn_ecmp_support
  dns_support                     = var.dns_support
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks
  
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Create Transit Gateway route tables
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.route_tables
  
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  
  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# Store default route table ID
data "aws_ec2_transit_gateway_route_table" "default" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
  
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.this.id]
  }
  
  depends_on = [aws_ec2_transit_gateway.this]
}

# Create default blackhole routes if needed
resource "aws_ec2_transit_gateway_route" "blackhole" {
  for_each = {
    for idx, route in var.blackhole_routes :
    "${route.route_table_key}-${route.cidr_block}" => route
  }
  
  destination_cidr_block = each.value.cidr_block
  blackhole              = true
  
  transit_gateway_route_table_id = lookup(
    aws_ec2_transit_gateway_route_table.this,
    each.value.route_table_key,
    data.aws_ec2_transit_gateway_route_table.default.id
  )
}

# If using Network Manager, create a global network
resource "aws_networkmanager_global_network" "this" {
  count = var.enable_network_manager ? 1 : 0
  
  description = "Global Network for ${var.name}"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-global-network"
    }
  )
}

# Register the Transit Gateway with Network Manager if enabled
resource "aws_networkmanager_transit_gateway_registration" "this" {
  count = var.enable_network_manager ? 1 : 0
  
  global_network_id   = aws_networkmanager_global_network.this[0].id
  transit_gateway_arn = aws_ec2_transit_gateway.this.arn
}