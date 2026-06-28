# AWS Network Modules

Leaf modules for networking. There is no aggregator module at this level;
environment compositions call each leaf module directly (same pattern as
`aws/compute`):

Subnets are defined explicitly via a `subnets` map keyed by subnet name, where
each entry sets its CIDR, AZ, and tier (`public` / `private`):

```hcl
module "vpc" {
  source = "../../../../terraform-shared-modules/aws/network/vpc"

  environment  = "staging"
  name_prefix  = "mw-stg-apse1"        # names the VPC/IGW/NAT/route tables
  cluster_name = "mw-stg-apse1-eks-01" # tags subnets for EKS/LB discovery
  vpc_cidr     = "10.10.0.0/16"

  subnets = {
    "mw-stg-apse1-snet-pub-01" = { cidr = "10.10.0.0/24",  az = "ap-southeast-1a", tier = "public" }
    "mw-stg-apse1-snet-prv-01" = { cidr = "10.10.10.0/24", az = "ap-southeast-1a", tier = "private" }
  }

  # NAT strategy: "regional" (single VPC-wide HA NAT, provider >= 6.24),
  # "per_az" (one NAT per AZ), or "single" (one shared NAT, cheapest).
  nat_gateway_mode = "regional"
}
```

### Route tables

By default the module auto-generates route tables (one public table → IGW, one
private table per private subnet → NAT). To make the routing explicit in your
own `main.tf`, pass `route_tables` (each table lists its routes directly) and
`route_table_associations`; these replace the auto-generated tables. `target`
resolves to a module-managed gateway: `igw`, or `nat` (assumes a single NAT —
`regional`/`single`):

```hcl
  route_tables = {
    "mw-stg-apse1-rt-pub-01" = {
      routes = [{ destination_cidr_block = "0.0.0.0/0", target = "igw" }]
    }
    "mw-stg-apse1-rt-prv-01" = {
      routes = [{ destination_cidr_block = "0.0.0.0/0", target = "nat" }]
    }
  }

  route_table_associations = {
    "mw-stg-apse1-snet-pub-01" = "mw-stg-apse1-rt-pub-01" # subnet name => route table name
    "mw-stg-apse1-snet-prv-01" = "mw-stg-apse1-rt-prv-01"
  }
```

## Modules

| Module | Purpose |
|--------|---------|
| `vpc`  | Self-contained VPC: the VPC, explicitly defined public/private subnets (name + CIDR + AZ + tier), Internet Gateway, NAT Gateway(s) (one per AZ by default), and the public/private route tables and associations. |
