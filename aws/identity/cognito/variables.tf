variable "name_prefix" {
  type = string
}

variable "domain_prefix" {
  type = string
}

variable "resource_server_identifier" {
  type = string
}

variable "oauth_scope_name" {
  type    = string
  default = "invoke"
}

variable "access_token_validity_hours" {
  type    = number
  default = 1
}

variable "deletion_protection" {
  type        = string
  description = "ACTIVE prevents accidental deletion of the user pool (recommended in production); INACTIVE allows it."
  default     = "INACTIVE"
}

variable "oauth_scope_description" {
  type        = string
  description = "Human-readable description of the OAuth scope."
  default     = "Allow access to the Max Weather API"
}
