variable "name_prefix" {
  type = string
}

variable "api_name" {
  type = string
}

variable "upstream_service_url" {
  type        = string
  default     = ""
  description = "Public upstream URL used when private_integration = false (HTTP_PROXY over the internet)."
}

variable "private_integration" {
  type        = bool
  default     = false
  description = "When true, API Gateway reaches the backend privately through a VPC Link to an internal NLB instead of a public URL. This makes API Gateway the only public entry point."
}

variable "vpc_link_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Private subnet IDs for the VPC Link ENIs (required when private_integration = true)."
}

variable "vpc_link_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs attached to the VPC Link ENIs (required when private_integration = true)."
}

variable "nlb_listener_arn" {
  type        = string
  default     = ""
  description = "ARN of the internal NLB listener that fronts ingress-nginx (required when private_integration = true). Resolved after the ingress is deployed."
}

variable "oauth_issuer_url" {
  type = string
}

variable "oauth_audience" {
  type = string
}

variable "oauth_scope" {
  type = string
}

variable "access_log_retention_in_days" {
  type    = number
  default = 14
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "Origins allowed by CORS. Use [\"*\"] for open access; restrict to known domains in production."
  default     = ["*"]
}

variable "cors_allow_methods" {
  type        = list(string)
  description = "HTTP methods allowed by CORS."
  default     = ["GET", "OPTIONS"]
}

variable "cors_allow_headers" {
  type        = list(string)
  description = "Request headers allowed by CORS."
  default     = ["Authorization", "Content-Type"]
}

variable "cors_max_age" {
  type        = number
  description = "How long (seconds) browsers may cache the CORS preflight response."
  default     = 300
}

variable "integration_timeout_milliseconds" {
  type        = number
  description = "Upstream integration timeout in milliseconds (max 30000 for HTTP APIs)."
  default     = 30000
}
