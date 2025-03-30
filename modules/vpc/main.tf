# VPC Module
# Creates a VPC with public, private, and database subnets across multiple AZs
# Modified to optionally create an Internet Gateway

# Create the VPC and subnets
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# Create an Internet Gateway only if enabled
resource "aws_internet_gateway" "this" {
  count = var.enable_igw ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
      
    }
  )
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones) > 0 && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${element(var.availability_zones, count.index)}"
      
      "kubernetes.io/role/elb" = "1"
    }
  )
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones) > 0 && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${element(var.availability_zones, count.index)}"
      
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# Create database subnets
resource "aws_subnet" "database" {
  count = length(var.availability_zones) > 0 && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
  
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.database_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-database-${element(var.availability_zones, count.index)}"
      
    }
  )
}

# Create a public route table
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public"
      
    }
  )
}

# Add a public route to the Internet Gateway if it exists
resource "aws_route" "public_internet_gateway" {
  count = var.enable_igw && length(var.public_subnets) > 0 ? 1 : 0
  
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  
  timeouts {
    create = "5m"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# Create private route tables (one per AZ if multiple NAT gateways)
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-private" : "${var.vpc_name}-private-${element(var.availability_zones, count.index)}"
      
    }
  )
}

# Create NAT gateways if enabled
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && length(var.public_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-nat" : "${var.vpc_name}-nat-${element(var.availability_zones, count.index)}"
      
    }
  )
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway && length(var.public_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  
  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  
  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.vpc_name}-nat" : "${var.vpc_name}-nat-${element(var.availability_zones, count.index)}"
      
    }
  )
  
  depends_on = [aws_internet_gateway.this]
}

# Add routes from private subnets to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  
  route_table_id         = element(aws_route_table.private[*].id, var.single_nat_gateway ? 0 : count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, var.single_nat_gateway ? 0 : count.index)
  
  timeouts {
    create = "5m"
  }
}

# Associate private subnets with the appropriate route tables
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, var.single_nat_gateway ? 0 : count.index)
}

# Create a route table for database subnets
resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-database"
      
    }
  )
}

# Associate database subnets with the database route table
resource "aws_route_table_association" "database" {
  count = length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
  
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database[0].id
}

# Create a VPN Gateway if enabled
resource "aws_vpn_gateway" "this" {
  count = var.enable_vpn_gateway ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-vgw"
      
    }
  )
}