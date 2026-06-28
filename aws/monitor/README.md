# AWS Monitor Modules

Leaf modules for logging / observability. There is no aggregator module at this
level; environment compositions call each leaf module directly (same pattern as
`aws/compute`). The `irsa-log-shipper` module consumes the log group ARNs that
`cloudwatch` outputs:

```hcl
module "cloudwatch" {
  source = "../../../../terraform-shared-modules/aws/monitor/cloudwatch"
  # ...
}

module "irsa_log_shipper" {
  source                    = "../../../../terraform-shared-modules/aws/monitor/irsa-log-shipper"
  application_log_group_arn = module.cloudwatch.application_log_group_arn
  cluster_log_group_arn     = module.cloudwatch.cluster_log_group_arn
  # ...
}
```

## Modules

| Module             | Purpose |
|--------------------|---------|
| `cloudwatch`       | CloudWatch log groups for application and EKS cluster logs. |
| `irsa-log-shipper` | IRSA IAM role/policy for the Fluent Bit log shipper service account. |
