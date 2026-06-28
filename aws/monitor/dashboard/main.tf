# Generic CloudWatch dashboard renderer. The module owns layout (it computes
# each widget's x/y from the row order and widget widths so callers never deal
# with coordinates) and the dashboard resource itself. Widget content is fully
# caller-defined: every widget passes through a raw CloudWatch `properties`
# object, so the same module can render an API dashboard, a database dashboard,
# an alarm overview, etc. without any change here.
locals {
  # Top of each row = sum of the heights of all preceding rows.
  row_y = [
    for r, _ in var.rows :
    r == 0 ? 0 : sum([for prev in slice(var.rows, 0, r) : prev.height])
  ]

  widgets = flatten([
    for r, row in var.rows : [
      for c, w in row.widgets : {
        type   = w.type
        width  = w.width
        height = row.height
        # x = sum of the widths of the widgets to the left in this row.
        x = c == 0 ? 0 : sum([for prev in slice(row.widgets, 0, c) : prev.width])
        y = local.row_y[r]
        # Inject the default region for non-text widgets (text widgets take no
        # region). A widget that sets its own region keeps it, because the
        # caller-provided properties win in the merge.
        properties = merge(
          (w.type != "text" && var.region != null) ? tomap({ region = var.region }) : tomap({}),
          w.properties,
        )
      }
    ]
  ])
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({ widgets = local.widgets })
}
