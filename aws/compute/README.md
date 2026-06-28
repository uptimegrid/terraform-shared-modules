# AWS Compute Modules

Leaf modules for container and instance compute. There is no aggregator module
at this level; environment compositions call each leaf module directly, for
example:

```hcl
module "ecr" {
  source = "../../../../terraform-shared-modules/aws/compute/ecr"
  # ...
}

module "eks" {
  source = "../../../../terraform-shared-modules/aws/compute/eks"
  # ...
}

module "ec2" {
  source = "../../../../terraform-shared-modules/aws/compute/ec2"
  # ...
}
```

## Modules

| Module | Purpose |
|--------|---------|
| `ecr`  | Elastic Container Registry repository for the application image. |
| `eks`  | EKS cluster, managed node group, OIDC provider, and access entries. |
| `ec2`  | Reusable single EC2 instance with security group and IAM instance profile (used for the self-hosted Jenkins controller and agent). |
