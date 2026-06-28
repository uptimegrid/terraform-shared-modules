variable "name_prefix" {
  type        = string
  description = "Resource name prefix, e.g. mw-prd-apse1. Used for the dashboard name."
}

variable "region" {
  type        = string
  description = "AWS region the dashboard widgets query metrics and logs in."
}

variable "api_id" {
  type        = string
  description = "API Gateway (HTTP API) id used as the ApiId metric dimension."
}

variable "api_stage" {
  type        = string
  description = "API Gateway stage name used as the Stage metric dimension."
  default     = "$default"
}

variable "application_log_group_name" {
  type        = string
  description = "Application log group name for the Logs Insights widget."
}

variable "access_log_group_name" {
  type        = string
  description = "API Gateway access log group name for the Logs Insights widget."
}
