# Local variables for complex logic and calculations

locals {
  # Define which VPC will serve as the egress VPC (with the IGW)
  egress_vpc_key = "management"  # We'll use the management VPC as our egress point
  
  # Define which VPCs need internet access but without their own IGW
  vpcs_requiring_internet = {
    for k, v in var.vpcs : k => v
    if k != local.egress_vpc_key && lookup(v, "requires_internet", true)
  }
  
  # Define route table propagation based on VPC type
  # This defines which VPCs can route to each other
  route_table_propagations = {
    # Production VPC propagates to all route tables except for dev
    "production" = [
      lookup(module.transit_gateway.route_table_ids, "production", ""),
      lookup(module.transit_gateway.route_table_ids, "shared-services", ""),
      lookup(module.transit_gateway.route_table_ids, "data", ""),
      lookup(module.transit_gateway.route_table_ids, "security", "")
    ]
    
    # Dev VPC propagates only to dev, shared services and security route tables
    "development" = [
      lookup(module.transit_gateway.route_table_ids, "non-production", ""),
      lookup(module.transit_gateway.route_table_ids, "shared-services", ""),
      lookup(module.transit_gateway.route_table_ids, "security", "")
    ]
    
    # Shared services propagates to all route tables
    "shared_services" = [
      lookup(module.transit_gateway.route_table_ids, "production", ""),
      lookup(module.transit_gateway.route_table_ids, "non-production", ""),
      lookup(module.transit_gateway.route_table_ids, "shared-services", ""),
      lookup(module.transit_gateway.route_table_ids, "data", ""),
      lookup(module.transit_gateway.route_table_ids, "security", "")
    ]
    
    # Data VPC propagates to prod, shared services and security
    "data" = [
      lookup(module.transit_gateway.route_table_ids, "production", ""),
      lookup(module.transit_gateway.route_table_ids, "shared-services", ""),
      lookup(module.transit_gateway.route_table_ids, "data", ""),
      lookup(module.transit_gateway.route_table_ids, "security", "")
    ]
    
    # Management/Egress VPC propagates to all route tables
    "management" = [
      lookup(module.transit_gateway.route_table_ids, "production", ""),
      lookup(module.transit_gateway.route_table_ids, "non-production", ""),
      lookup(module.transit_gateway.route_table_ids, "shared-services", ""),
      lookup(module.transit_gateway.route_table_ids, "data", ""),
      lookup(module.transit_gateway.route_table_ids, "security", "")
    ]
  }
  
  # Define blackhole routes - these prevent certain VPCs from reaching each other
  blackhole_routes = {
    # Example: Prevent dev from reaching production directly
    "non-production" = {
      "production_cidr" = "10.0.0.0/16"
    }
  }
  
  # Add any additional complex calculations here
  all_vpc_cidr_blocks = {
    for k, v in var.vpcs : k => v.cidr_block
  }
}