variable "dashboard_name" {
  type        = string
  description = "Name of the CloudWatch dashboard."
}

variable "region" {
  type        = string
  description = "Default AWS region applied to any widget that does not set its own."
  default     = null
}

variable "rows" {
  description = <<-EOT
    Ordered rows of widgets. Widgets within a row are laid out left-to-right;
    rows stack top-to-bottom. The module computes each widget's x/y from the
    widget widths and the row order, so callers never manage coordinates.

    Each widget carries a raw CloudWatch widget `properties` object (passed
    through verbatim), which keeps the module agnostic to widget content:
      - type:       widget type, e.g. "metric", "log", "text", "alarm".
      - width:      widget width in grid columns (the grid is 24 wide).
      - properties: the CloudWatch widget properties object for that type.
                    `region` is injected from var.region when not set.

    Typed as `any` (rather than a concrete object) because widget `properties`
    objects have intentionally different shapes per widget type, which a
    `list(object(...))` would try (and fail) to unify into one element type.
    Expected shape per element:
      {
        height  = number
        widgets = [{ type = string, width = number, properties = object }]
      }
  EOT
  type = any
}
