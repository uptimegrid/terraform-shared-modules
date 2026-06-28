variable "environment" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_ver" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "cluster_log_types" {
  type = list(string)
}

variable "node_group_name" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_disk_size" {
  type = number
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND for stable production capacity, or SPOT to cut cost in non-critical environments."
  default     = "ON_DEMAND"
}

variable "node_ami_type" {
  type        = string
  description = "Managed node group AMI type. AL2023_x86_64_STANDARD is required for Kubernetes 1.33+ (AL2_x86_64 is only supported up to 1.32)."
  default     = "AL2023_x86_64_STANDARD"
}

variable "cluster_admin_principal_arns" {
  type        = list(string)
  description = "IAM principal ARNs granted EKS cluster-admin access (e.g. the Jenkins agent role)."
  default     = []
}
