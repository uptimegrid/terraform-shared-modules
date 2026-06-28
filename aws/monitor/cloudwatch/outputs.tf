output "application_log_group_name" {
  value = aws_cloudwatch_log_group.application.name
}

output "cluster_log_group_name" {
  value = aws_cloudwatch_log_group.cluster.name
}

output "application_log_group_arn" {
  value = aws_cloudwatch_log_group.application.arn
}

output "cluster_log_group_arn" {
  value = aws_cloudwatch_log_group.cluster.arn
}
