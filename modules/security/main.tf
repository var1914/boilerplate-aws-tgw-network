# Security Module for Transit Gateway Network
# Handles security-related resources such as VPC Flow Logs, NACLs, and Network Firewall

# Create VPC Flow Logs for each VPC
resource "aws_flow_log" "vpc_flow_logs" {
  for_each = var.enable_flow_logs ? var.vpcs : {}

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[each.key].arn
  traffic_type         = "ALL"
  vpc_id               = each.value
  
  tags = merge(
    var.tags,
    {
      Name = "flow-logs-${each.key}"
    }
  )
}

# Create CloudWatch Log Groups for Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  for_each = var.enable_flow_logs ? var.vpcs : {}

  name              = "/aws/vpc-flow-logs/${each.key}"
  retention_in_days = var.flow_logs_retention
  
  tags = merge(
    var.tags,
    {
      Name = "flow-logs-${each.key}"
    }
  )
}

# Create IAM Role for Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "vpc-flow-logs-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# Create IAM Policy for Flow Logs
resource "aws_iam_role_policy" "flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs_role[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Register Transit Gateway with Network Manager if enabled
resource "aws_networkmanager_global_network" "this" {
  count = var.enable_transit_gateway_network_manager ? 1 : 0
  
  description = "Global Network for Transit Gateway"
  
  tags = merge(
    var.tags,
    {
      Name = "tgw-global-network"
    }
  )
}

resource "aws_networkmanager_transit_gateway_registration" "this" {
  count = var.enable_transit_gateway_network_manager ? 1 : 0
  
  global_network_id   = aws_networkmanager_global_network.this[0].id
  transit_gateway_arn = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:transit-gateway/${var.transit_gateway_id}"
  
  depends_on = [aws_networkmanager_global_network.this]
}

# Create Network Firewall if enabled
resource "aws_networkfirewall_firewall_policy" "this" {
  count = var.enable_network_firewall ? 1 : 0
  
  name = "network-firewall-policy"
  
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful[0].arn
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "network-firewall-policy"
    }
  )
}

resource "aws_networkfirewall_rule_group" "stateful" {
  count = var.enable_network_firewall ? 1 : 0
  
  capacity = 100
  name     = "stateful-rule-group"
  type     = "STATEFUL"
  
  rule_group {
    rules_source {
      rules_string = <<EOF
# Allow HTTPS to all destinations
pass tcp any any -> any 443 (msg:"Allow HTTPS"; sid:1; rev:1;)
# Allow HTTP to all destinations
pass tcp any any -> any 80 (msg:"Allow HTTP"; sid:2; rev:1;)
# Allow DNS
pass udp any any -> any 53 (msg:"Allow DNS"; sid:3; rev:1;)
pass tcp any any -> any 53 (msg:"Allow DNS over TCP"; sid:4; rev:1;)
EOF
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "stateful-rule-group"
    }
  )
}

# Create Network Firewall - we place this in the egress VPC if specified
resource "aws_networkfirewall_firewall" "this" {
  count = var.enable_network_firewall && var.egress_vpc_id != "" ? 1 : 0
  
  name                = "network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this[0].arn
  vpc_id              = var.egress_vpc_id
  
  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids
    
    content {
      subnet_id = subnet_mapping.value
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "network-firewall"
    }
  )
}

# Create Custom NACLs if needed
resource "aws_network_acl" "custom" {
  for_each = var.nacl_rules
  
  vpc_id = each.value.vpc_id
  
  dynamic "ingress" {
    for_each = each.value.ingress
    
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  
  dynamic "egress" {
    for_each = each.value.egress
    
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "nacl-${each.key}"
    }
  )
}

# Get current region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}