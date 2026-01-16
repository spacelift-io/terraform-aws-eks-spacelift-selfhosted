# With VCS Gateway Example

This example demonstrates how to deploy Spacelift Self-Hosted on EKS with the VCS Gateway enabled.

The VCS Gateway allows you to connect [remote VCS agents](https://docs.spacelift.io/concepts/vcs-agent-pools.html) to Spacelift, enabling integration with VCS providers that are not directly accessible from the Spacelift server.

## Architecture

The VCS Gateway service exposes two listeners:

- **gRPC (port 1984)** - External endpoint for [remote VCS Agents](https://docs.spacelift.io/concepts/vcs-agent-pools.html), exposed via an Application Load Balancer
- **HTTP (port 1985)** - Internal endpoint for Spacelift services (server, drain), accessed via Kubernetes service discovery

```mermaid
architecture-beta
    group internet(internet)[External]
    group aws(cloud)[AWS]
    group eks(server)[EKS Cluster] in aws

    service vcs_agent(server)[VCS Agent] in internet
    service alb(internet)[ALB] in aws
    service vcs_gateway(server)[VCS Gateway] in eks
    service server(server)[Server] in eks
    service drain(server)[Drain] in eks

    vcs_agent:R --> L:alb
    alb:R --> L:vcs_gateway
    server:B --> T:vcs_gateway
    drain:B --> T:vcs_gateway
```

| Connection                    | Protocol | Port | Path                                                             |
| ----------------------------- | -------- | ---- | ---------------------------------------------------------------- |
| VCS Agent → ALB → VCS Gateway | gRPC     | 1984 | `vcs-gateway.example.com:443` (TLS terminated at ALB)            |
| Server → VCS Gateway          | HTTP     | 1985 | `http://spacelift-vcs-gateway:1985` (internal service discovery) |
| Drain → VCS Gateway           | HTTP     | 1985 | `http://spacelift-vcs-gateway:1985` (internal service discovery) |

## Prerequisites

- An ACM certificate for the VCS Gateway domain (e.g., `vcs-gateway.mycorp.io`) - this must be **separate from the server certificate** as the VCS Gateway runs on its own domain and load balancer
- DNS configuration to point the VCS Gateway domain to the created load balancer

## Usage

```hcl
module "spacelift_eks_selfhosted" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted"

  aws_region         = "us-east-1"
  server_domain      = "spacelift.example.com"
  rds_engine_version = "16.1"

  # VCS Gateway configuration
  vcs_gateway_domain  = "vcs-gateway.example.com"
  vcs_gateway_acm_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
}
```

## Inputs

| Name                | Description                                                 | Type   | Required |
| ------------------- | ----------------------------------------------------------- | ------ | -------- |
| aws_region          | AWS region to deploy resources                              | string | yes      |
| server_domain       | The domain that Spacelift is being hosted on                | string | yes      |
| vcs_gateway_domain  | The domain for the VCS Gateway external endpoint            | string | yes      |
| vcs_gateway_acm_arn | AWS Certificate Manager ARN for the VCS Gateway certificate | string | yes      |
