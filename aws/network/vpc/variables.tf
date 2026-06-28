variable "environment" {
  type        = string
  description = "Environment name (used in resource tags)."
}

variable "name_prefix" {
  type        = string
  description = "Prefix used to name the non-subnet resources (VPC, IGW, NAT, route tables), e.g. mw-stg-apse1."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name used ONLY to tag subnets for Kubernetes load balancer discovery (not a naming input)."
}

variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR block."
}

variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
    tier = string # "public" or "private"
  }))
  description = "Explicit subnet definitions keyed by the subnet name. Each entry sets its CIDR range, availability zone, and tier (public or private)."

  validation {
    condition     = alltrue([for s in values(var.subnets) : contains(["public", "private"], s.tier)])
    error_message = "Each subnet 'tier' must be either 'public' or 'private'."
  }

  validation {
    condition = (
      length([for s in values(var.subnets) : s if s.tier == "public"]) == 0 ||
      length([for s in values(var.subnets) : s if s.tier == "public"]) >= 2
    )
    error_message = "Use either zero public subnets (e.g. with a Regional NAT Gateway, which needs none) or at least two in different AZs for high availability."
  }

  validation {
    condition     = length([for s in values(var.subnets) : s if s.tier == "private"]) >= 1
    error_message = "At least one private subnet is required."
  }
}

variable "nat_gateway_mode" {
  type        = string
  description = <<-EOT
    NAT Gateway strategy for outbound egress:
      - "per_az"   : one zonal NAT Gateway per public AZ (24/7 HA, classic pattern).
      - "single"   : one zonal NAT Gateway shared by all private subnets (cheapest, AZ-level SPOF).
      - "regional" : a single Regional NAT Gateway (auto mode) that automatically
                     spans all AZs with workloads (HA, no public subnet needed to host it).
                     Requires AWS provider >= 6.24.
  EOT
  default     = "per_az"

  validation {
    condition     = contains(["per_az", "single", "regional"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: per_az, single, regional."
  }
}

variable "route_tables" {
  type = map(object({
    routes = optional(list(object({
      destination_cidr_block = string
      target                 = string # "igw" | "nat"
    })), [])
  }))
  default     = {}
  description = <<-EOT
    Optional explicit route tables, keyed by route table name. Each table lists its
    routes directly (destination CIDR + target) so the full routing is visible in
    the caller's main.tf. `target` selects a module-managed gateway:
      - "igw" : the Internet Gateway.
      - "nat" : the VPC's NAT Gateway (assumes a single NAT — "regional"/"single").
    An empty `routes` list creates a table with only the implicit local route.
    When set, these REPLACE the module's auto-generated route tables and must be
    paired with `route_table_associations`.
  EOT

  validation {
    condition = alltrue([
      for rt in values(var.route_tables) : alltrue([
        for r in rt.routes : contains(["igw", "nat"], r.target)
      ])
    ])
    error_message = "Each route's target must be one of: igw, nat."
  }
}

variable "route_table_associations" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Optional map of subnet name => route table name (keys are subnet names from
    `subnets`; values are route table names from `route_tables`). Required when
    `route_tables` is set; each subnet should appear exactly once.
  EOT
}
