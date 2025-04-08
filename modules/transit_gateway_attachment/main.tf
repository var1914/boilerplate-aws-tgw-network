# Transit Gateway Attachment Module
# Creates VPC attachments to a Transit Gateway and configures routing

# Create the Transit Gateway VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  
  dns_support                                   = var.dns_support
  ipv6_support                                  = var.ipv6_support
  appliance_mode_support                        = var.appliance_mode_support
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  
  tags = var.tags
}

# Associate the VPC attachment with the specified route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = var.route_table_id != null ? 1 : 0
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.route_table_id
}

# Configure route propagations for the VPC attachment
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = toset([for rt in var.propagate_to_route_tables : rt if rt != ""])
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value
}

# Add routes from the VPC to the Transit Gateway
resource "aws_route" "to_tgw" {
  count = length(var.vpc_route_table_ids)
  
  route_table_id         = var.vpc_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}