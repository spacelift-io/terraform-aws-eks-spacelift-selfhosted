# With Flows Example

This example deploys Spacelift Self-Hosted on EKS together with [Spacelift Flows](https://docs.spacelift.io/flows/introduction).

Flows runs in the same cluster and namespace as Spacelift, and uses the same database cluster. On top of that the module creates a bucket with a KMS key of its own and an IAM role for it.

## Prerequisites

- A license that includes Flows.
- An ACM certificate for the Flows domain. It must be **separate from the server certificate** and cover:
  - `flows.spacelift.io`
  - `*.endpoints.flows.spacelift.io`
  - `oauth.flows.spacelift.io`
  - `mcp.flows.spacelift.io`
  - `gateway.flows.spacelift.io`, if you set `expose_gateway`
- DNS records that point those names to the Flows load balancer.

## Usage

See [main.tf](main.tf). The `flows` block is the only Flows-specific part: `domain`, `acm_arn`, `organization_name`, `admin_email` and `admin_password` are required, `database_url`, `expose_gateway` and `service_account_name` are optional.

## Next Steps

After applying, re-apply the `kubernetes_secrets` and `kubernetes_ingress_class` outputs, and deploy the Helm chart again with the new `helm_values`.

The Flows agents are not deployed by this module. Use the `flows_agent_pool_id` and `flows_agent_pool_token` outputs to configure them.
