variable "name" {
  type        = string
  description = "Full resource name used as the base for the instance and its dependent resources (e.g. mw-prd-apse1-ec2-jenkins-ctrl-01)."
}

variable "vpc_id" {
  type        = string
  description = "VPC the instance and its security group are created in."
}

variable "subnet_id" {
  type        = string
  description = "Subnet the instance is launched into (use a private subnet for SSM-managed instances)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.small"
}

variable "ami_id" {
  type        = string
  description = "AMI to launch. When empty, the latest Amazon Linux 2023 x86_64 AMI is resolved automatically."
  default     = ""
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GiB."
  default     = 30
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to assign a public IP. Keep false for private-subnet instances reached via SSM."
  default     = false
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name. Prefer SSM Session Manager over SSH keys."
  default     = null
}

variable "user_data" {
  type        = string
  description = "Optional user-data script used to bootstrap the instance."
  default     = null
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Inbound security group rules. Defaults to none (SSM uses outbound only)."
  default     = []
}

variable "iam_managed_policy_arns" {
  type        = list(string)
  description = "Managed IAM policy ARNs attached to the instance role (e.g. SSM, ECR)."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources."
  default     = {}
}
