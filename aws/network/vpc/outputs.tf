output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

# Maps keyed by the explicit subnet name so callers can select specific subnets
# (e.g. route only the EKS subnets to the cluster and the EC2 subnet to Jenkins).
output "public_subnet_ids_by_name" {
  value = { for name, subnet in aws_subnet.public : name => subnet.id }
}

output "private_subnet_ids_by_name" {
  value = { for name, subnet in aws_subnet.private : name => subnet.id }
}

output "availability_zones" {
  value = distinct([for s in var.subnets : s.az])
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateway(s). For zonal modes these are the EIPs; for regional mode AWS manages the addresses, exposed via regional_nat_gateway_address."
  value = local.is_regional ? [
    for a in aws_nat_gateway.regional[0].regional_nat_gateway_address : a.public_ip
  ] : [for eip in aws_eip.nat : eip.public_ip]
}
