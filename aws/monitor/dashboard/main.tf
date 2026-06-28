# Operational dashboard that surfaces the key signals for the weather API:
# request volume and error rate, latency, plus log views for the application
# and the API Gateway access logs. Built as code so the evidence is
# reproducible and version-controlled rather than hand-drawn in the console.
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name_prefix}-dashboard-01"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# ${var.name_prefix} - Max Weather API\nKey operational metrics for the public API Gateway endpoint and the application running on EKS."
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "API requests and errors"
          region = var.region
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", var.api_id, "Stage", var.api_stage, { label = "Requests" }],
            ["AWS/ApiGateway", "4xx", "ApiId", var.api_id, "Stage", var.api_stage, { label = "4xx" }],
            ["AWS/ApiGateway", "5xx", "ApiId", var.api_id, "Stage", var.api_stage, { label = "5xx" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "Latency (ms)"
          region = var.region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", var.api_id, "Stage", var.api_stage, { stat = "Average", label = "Latency avg" }],
            ["AWS/ApiGateway", "Latency", "ApiId", var.api_id, "Stage", var.api_stage, { stat = "p99", label = "Latency p99" }],
            ["AWS/ApiGateway", "IntegrationLatency", "ApiId", var.api_id, "Stage", var.api_stage, { stat = "Average", label = "Integration latency avg" }],
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 8
        width  = 24
        height = 6
        properties = {
          title  = "Application weather requests"
          region = var.region
          view   = "table"
          query  = "SOURCE '${var.application_log_group_name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 14
        width  = 24
        height = 6
        properties = {
          title  = "API Gateway access logs by status"
          region = var.region
          view   = "table"
          query  = "SOURCE '${var.access_log_group_name}' | stats count(*) as requests by status | sort requests desc"
        }
      },
    ]
  })
}
