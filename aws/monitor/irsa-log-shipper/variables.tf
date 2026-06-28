variable "name_prefix" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "log_shipper_namespace" {
  type    = string
  default = "kube-system"
}

variable "log_shipper_service_account_name" {
  type    = string
  default = "aws-for-fluent-bit"
}

variable "application_log_group_arn" {
  type = string
}

variable "cluster_log_group_arn" {
  type = string
}
