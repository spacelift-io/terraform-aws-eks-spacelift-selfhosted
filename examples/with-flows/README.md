# With Flows Example

This example deploys Spacelift Self-Hosted on EKS together with [Spacelift Flows](https://docs.spacelift.io/flows/introduction).

Flows runs in the same cluster and namespace as Spacelift, and uses the same database cluster. On top of that the module creates a bucket with a KMS key of its own and an IAM role for it, and puts Flows into the `kubernetes_secrets`, `kubernetes_ingress_class` and `helm_values` outputs. Flows creates its own database on the cluster the first time it starts.

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

See [main.tf](main.tf). The `flows` block is the only Flows-specific part: `domain`, `acm_arn`, `organization_name`, `admin_email` and `admin_password` are required, `database_url`, `expose_gateway`, `service_account_name` and `extra_config` are optional.

Flows needs `license_token` too. The module puts it into the Flows config, and Flows doesn't start without it.

## Images

The Flows image follows the same rule as the backend image. With the default `create_container_registry = true`, the module creates ECR repositories for the Flows backend, agent and Kubernetes JS executor images, and `helm_values` points Flows at the backend one, so push the images there. With `spacelift_registry_pull_secret_name` set, Flows pulls from `oci.spacelift.io` with that secret.

## Extra configuration

Flows reads its settings from a config file that the module generates into `kubernetes_secrets`, and ignores environment variables once it has one. For anything the module doesn't set there, like SMTP or the log level, use `extra_config`:

```hcl
flows = {
  # ...
  extra_config = {
    logging = { level = "debug" }
  }
}
```

A section the module writes too, like `server`, is merged with yours, and your values win.

## Next Steps

After applying, re-apply the `kubernetes_secrets` and `kubernetes_ingress_class` outputs, and deploy the Helm chart again with the new `helm_values`.

The Flows agents are not deployed by this module. Use the `flows_agent_pool_id` and `flows_agent_pool_token` outputs to configure them.
