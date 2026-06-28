# AWS Identity Modules

Leaf modules for identity / authentication. There is no aggregator module at
this level; environment compositions call each leaf module directly (same
pattern as `aws/compute`):

```hcl
module "cognito" {
  source = "../../../../terraform-shared-modules/aws/identity/cognito"
  # ...
}
```

## Modules

| Module    | Purpose |
|-----------|---------|
| `cognito` | Cognito user pool, resource server, machine-to-machine app client, and hosted domain for OAuth2 `client_credentials` tokens. |
