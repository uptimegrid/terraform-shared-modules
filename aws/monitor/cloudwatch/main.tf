locals {
  application_log_group_name = "/${var.name_prefix}/app-01"
  cluster_log_group_name     = "/aws/eks/${var.cluster_name}/cluster"
}

resource "aws_cloudwatch_log_group" "application" {
  name              = local.application_log_group_name
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = local.cluster_log_group_name
  retention_in_days = var.log_retention_in_days
}
