variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type        = string
  description = "MUTABLE allows overwriting tags (handy in staging); IMMUTABLE prevents it (recommended in production for image provenance)."
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "Allow deleting the repository even when it still contains images. Keep false in production to avoid accidental loss."
  default     = true
}

variable "scan_on_push" {
  type        = bool
  description = "Run a vulnerability scan automatically when an image is pushed."
  default     = true
}

variable "image_retention_count" {
  type        = number
  description = "Number of most-recent images the lifecycle policy keeps before expiring older ones."
  default     = 20
}
