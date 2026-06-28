# Terraform Shared Modules

This repository holds Terraform building blocks grouped first by cloud provider, then by infrastructure capability.

## Why Provider-First

Requirement 7 asks for Terraform that is parameterized so the application can be moved to another cloud with minimal effort. That does not mean one module should try to provision AWS, Azure, GCP, and OCI with a single implementation. It means the Terraform repository should keep portability intentional.

This repository uses the following shape:

- `aws/`
- `azure/`
- `gcp/`
- `oci/`

Inside each provider folder, modules are grouped by function such as:

- `compute/`
- `database/`
- `network/`
- `monitor/`

Additional provider-specific capabilities can live alongside that common baseline, such as `edge/` and `identity/` for AWS.

## Contract

- The platform repository composes environments from this repository.
- Provider implementations stay isolated from environment definitions.
- Module inputs should be parameterized and environment-agnostic where practical.
- Current assessment delivery still targets AWS, because AWS is the execution requirement.

## Versioning

Modules are versioned with **Git tags following Semantic Versioning** (`vMAJOR.MINOR.PATCH`):

- **MAJOR** — a breaking change to a module's input/output contract (rename or
  remove a variable, change a default that alters created resources).
- **MINOR** — a new, backward-compatible input or capability (existing callers
  keep working without changes).
- **PATCH** — a bug fix or documentation change with no interface impact.

### How consumers pin a version

In real CI and cross-repo usage, the platform repository should reference modules
by an immutable Git ref, not a moving branch:

```hcl
module "vpc" {
  source = "git::https://github.com/uptimegrid/terraform-shared-modules.git//aws/network/vpc?ref=v1.3.0"
  # ...
}
```

This guarantees that a `terraform apply` produces the same plan regardless of when
it runs, and module upgrades become deliberate, reviewable bumps of the `?ref=`.

### Why this assessment uses relative paths

For the assessment, both repositories live side by side in one workspace and the
env composition references modules via relative paths
(`../../../../terraform-shared-modules/aws/...`). This keeps local iteration fast
and lets a reviewer read both repos together. The Jenkins infra pipeline mirrors
the same layout by checking out `terraform-shared-modules` as a **sibling
directory**, pinned to `SHARED_MODULES_REF` (see `Jenkinsfile.infra`). To move to
true version pinning, switch that ref from `main` to a tag and/or change the env
`source` values to the `git::...?ref=vX.Y.Z` form above.
