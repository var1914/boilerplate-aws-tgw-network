# AWS Transit Gateway Network Architecture with Centralized Egress

This Terraform module provides a ready-to-deploy AWS Transit Gateway architecture with a centralized egress model. It allows you to efficiently connect multiple VPCs while optimizing costs by using a single Internet Gateway.

## Quick Start

1. Clone this repository
2. Edit `terraform.tfvars` with your desired VPC configurations
3. Run:
```bash
terraform init
terraform plan
terraform apply
```

## What This Does

This module:
- Creates multiple VPCs for your different environments and workloads
- Sets up a Transit Gateway as the central hub for all network traffic
- Configures a single Internet Gateway in one VPC for all internet-bound traffic
- Sets up proper routing so all VPCs can communicate with each other and the internet
- Implements security best practices with VPC Flow Logs

## Prerequisites

- Terraform ≥ 1.0.0
- An AWS account with permissions to create VPCs, Transit Gateway, and related resources
- The AWS CLI configured with appropriate credentials

## Configuration

### Basic VPC Setup

Just specify your VPCs in the `terraform.tfvars` file:

```hcl
vpcs = {
  "production" = {
    cidr_block         = "10.0.0.0/16"
    name               = "production"
    availability_zones = ["us-east-1a", "us-east-1b"]
    public_subnets     = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
    database_subnets   = ["10.0.20.0/24", "10.0.21.0/24"]
    enable_igw         = false # No IGW needed as we're using centralized egress
    requires_internet  = true
    tags = {
      Type = "Production"
    }
  },
  
  # Add more VPCs as needed
}
```

### Centralized Egress Configuration

Specify which VPC will serve as the egress point for internet traffic:

```hcl
centralized_egress = {
  enabled        = true
  egress_vpc_key = "management" # Name of the VPC with the IGW
  create_igw_routes = true
}
```

## Use Cases

### Use Case 1: Multi-Environment Enterprise Architecture

**Scenario**: An enterprise with distinct environments (dev, test, prod) needs to ensure proper isolation while allowing controlled communication paths.

**Benefits**:
- Development teams can't directly access production resources
- Shared services (like monitoring, logging) can reach all environments
- Centralized internet access provides a single point for security monitoring
- Cost savings by having one Internet Gateway instead of multiple

**Implementation**:
```hcl
vpcs = {
  "production" = { cidr_block = "10.0.0.0/16", ... },
  "development" = { cidr_block = "10.1.0.0/16", ... },
  "testing" = { cidr_block = "10.2.0.0/16", ... },
  "shared_services" = { cidr_block = "10.3.0.0/16", ... },
  "mgmt_egress" = { 
    cidr_block = "10.4.0.0/16",
    enable_igw = true, 
    ... 
  }
}
```

### Use Case 2: Cost-Optimized Startup Infrastructure

**Scenario**: A growing startup needs to optimize AWS costs while maintaining good network practices.

**Benefits**:
- Up to 40% cost reduction by eliminating multiple NAT Gateways
- Simplified network management
- Ability to easily add new VPCs as the company grows

**Implementation**:
```hcl
vpcs = {
  "app" = { cidr_block = "10.0.0.0/16", enable_nat_gateway = false, ... },
  "data" = { cidr_block = "10.1.0.0/16", enable_nat_gateway = false, ... },
  "egress" = { 
    cidr_block = "10.2.0.0/16", 
    enable_igw = true,
    enable_nat_gateway = true,
    ... 
  }
}
```

### Use Case 3: Regulated Industry Compliance

**Scenario**: A financial or healthcare company needs to meet strict regulatory requirements.

**Benefits**:
- Centralized internet egress for comprehensive traffic inspection
- Ability to insert security appliances in the egress VPC
- Proper segregation of sensitive data environments
- Simplified compliance reporting with centralized flow logs

**Implementation**:
```hcl
vpcs = {
  "customer_data" = { cidr_block = "10.0.0.0/16", ... },
  "payment_processing" = { cidr_block = "10.1.0.0/16", ... },
  "internal_apps" = { cidr_block = "10.2.0.0/16", ... },
  "security_egress" = { 
    cidr_block = "10.3.0.0/16", 
    enable_igw = true,
    ... 
  }
}

security_config = {
  enable_flow_logs = true,
  flow_logs_retention = 90,
  enable_network_firewall = true,
  ...
}
```

## Common Customizations

### Adding a New VPC

Add a new entry to the `vpcs` map in your `terraform.tfvars` file:

```hcl
"new_vpc" = {
  cidr_block = "10.5.0.0/16",
  name = "new-application",
  availability_zones = ["us-east-1a", "us-east-1b"],
  public_subnets = ["10.5.0.0/24", "10.5.1.0/24"],
  private_subnets = ["10.5.10.0/24", "10.5.11.0/24"],
  enable_igw = false,
  requires_internet = true,
  tags = { Type = "Application" }
}
```

### Modifying Transit Gateway Route Tables

Edit the `tgw_route_tables` variable to adjust routing behavior:

```hcl
tgw_route_tables = {
  "isolated" = {
    name = "isolated-rt",
    tags = { Type = "Isolated" }
  },
  # More route tables...
}
```

Then update the route table associations in `locals.tf`.

## Troubleshooting

### Cannot Access Internet from VPC

1. Verify the Transit Gateway route table for your VPC contains a default route (0.0.0.0/0) pointing to the egress VPC attachment
2. Check that your egress VPC has a properly configured Internet Gateway
3. Verify the default route in your VPC's route table points to the Transit Gateway

### VPCs Cannot Communicate with Each Other

1. Verify Transit Gateway route propagation settings in `locals.tf`
2. Check for any blackhole routes that might be blocking traffic
3. Verify security groups and NACLs are properly configured

## Security Best Practices

This module follows AWS security best practices:

- VPC Flow Logs for network traffic monitoring
- Traffic segmentation through Transit Gateway route tables
- Centralized egress for better traffic inspection
- No direct internet access from application VPCs

## Cost Optimization

This architecture significantly reduces costs by:

- Using a single Internet Gateway instead of one per VPC
- Reducing the number of NAT Gateways needed
- Eliminating EC2-based NAT instances
- Cutting data transfer costs with optimized routing

## Maintenance and Updates

1. Use version pinning for stability
   ```hcl
   module "transit_gateway_network" {
     source = "github.com/your-repo/aws-transit-gateway-network?ref=v1.0.0"
     # ...
   }
   ```

2. Review and apply changes carefully with a plan-first approach
   ```bash
   terraform plan -out=plan.out
   terraform apply plan.out
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
