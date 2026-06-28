# AWS Edge Modules

Leaf modules for edge / API exposure. There is no aggregator module at this
level; environment compositions call each leaf module directly (same pattern as
`aws/compute`):

```hcl
module "api_gateway" {
  source = "../../../../terraform-shared-modules/aws/edge/api-gateway"
  # ...
}
```

## Modules

| Module        | Purpose |
|---------------|---------|
| `api-gateway` | HTTP API Gateway with a JWT authorizer. Supports either a public `HTTP_PROXY` integration to an upstream URL, or (via `private_integration = true`) a VPC Link private integration to an internal NLB so API Gateway is the only public entry point. |
