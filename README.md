# ☁️ Terraform module for Spacelift on Google Cloud Platform

This module creates a base infrastructure for a self-hosted Spacelift instance on Google Cloud Platform.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## ✨ Usage

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-google-spacelift-selfhosted?ref=v0.0.5"

  region         = "europe-west1"
  project        = "spacelift-production"
  website_domain = "spacelift.mycompany.com"
  labels         = {"app" = "spacelift"}
}
```

The module creates:

- IAM resources
  - IAM service account for the GKE cluster
  - IAM service account for the Spacelift backend services, meant to be used by the Spacelift backend
- Network resources
  - a compute network for the infrastructure
  - a compute subnetwork for the GKE cluster
- Artifact repository
  - a Google Artifact Registry repository for storing Docker images
  - a PUBLIC Google Artifact Registry repository for storing Docker images for workers (if external workers are enabled)
- Database resources
  - a Postgres Cloud SQL instance
- Storage resources
  - various buckets for storing run metadata, run logs, workspaces, stack states etc.
- GKE autopilot cluster  
  - a Kubernetes cluster to install Spacelift on

### Inputs

| Name                            | Description                                                                                                                                              | Type        | Default               | Required |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | --------------------- | -------- |
| region                          | The region in which the resources will be created.                                                                                                       | string      | -                     | yes      |
| project                         | The ID of the project in which the resources will be created.                                                                                            | string      | -                     | yes      |
| website_domain                  | The domain under which the Spacelift instance will be hosted. This is used for the CORS rules of one of the buckets. Do not prefix it with the protocol. | string      | -                     | yes      |
| labels                          | A map of labels to apply to all resources.                                                                                                               | map(string) | {}                    | no       |
| k8s_namespace                   | The namespace in which the Spacelift backend service will be deployed.                                                                                   | string      | spacelift             | no       |
| app_service_account_name        | The name of the service account (GSA) used by the GKE cluster.                                                                                           | string      | spacelift-backend     | no       |
| enable_database                 | Switch this to false if you don't want to deploy a new Cloud SQL instance for Spacelift.                                                                 | bool        | true                  | no       |
| database_edition                | Edition of the Cloud SQL instance. Can be either ENTERPRISE or ENTERPRISE_PLUS.                                                                          | string      | ENTERPRISE            | no       |
| database_tier                   | The tier of the Cloud SQL instance.                                                                                                                      | string      | db-perf-optimized-N-4 | no       |
| database_deletion_protection    | Whether the Cloud SQL instance should have [deletion protection](https://cloud.google.com/sql/docs/mysql/deletion-protection) enabled.                   | bool        | true                  | no       |
| enable_external_workers         | Switch this to true if you want to run workers from outside of the VPC created by this module.                                                           | bool        | false                 | no       |
| ip_cidr_range                   | The IP CIDR range for the subnetwork used by the GKE cluster.                                                                                            | string      | 10.0.0.0/16           | no       |
| secondary_ip_range_for_services | The secondary IP range for the subnetwork used by the GKE cluster. This range is used for services.                                                      | string      | 192.168.16.0/22       | no       |
| secondary_ip_range_for_pods     | The secondary IP range for the subnetwork used by the GKE cluster. This range is used for pods.                                                          | string      | 192.168.0.0/20        | no       |
| enable_network                  | Switch this to false to disable creating a new VPC. In that case you need to reference `network` and `subnetwork` variables.                             | bool        | true                  | no       |
| enable_gke                      | Switch this to false to disable deployment of a GKE cluster                                                                                              | bool        | true                  | no       |

### Outputs

| Name                            | Description                                                                                                                                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| region                          | The region in which the resources were created.                                                                                                                                                  |
| project                         | The ID of the project in which the resources were created.                                                                                                                                       |
| gke_service_account_email       | The email of the service account used by the GKE cluster.                                                                                                                                        |
| backend_service_account_email   | The email of the service account meant to be used by the Spacelift backend service.                                                                                                              |
| network_id                      | ID of the network the Spacelift infrastructure is deployed in.                                                                                                                                   |
| network_name                    | Name of the network the Spacelift infrastructure is deployed in.                                                                                                                                 |
| network_link                    | Self-link of the network the Spacelift infrastructure is deployed in.                                                                                                                            |
| gke_subnetwork_id               | ID of the subnetwork the GKE cluster is deployed in.                                                                                                                                             |
| gke_subnetwork_name             | Name of the subnetwork the GKE cluster is deployed in.                                                                                                                                           |
| gke_cluster_name                | Name of the GKE cluster.                                                                                                                                                                         |
| gke_public_v4_address           | Public IPv4 address of the GKE cluster.                                                                                                                                                          |
| gke_public_v6_address           | Public IPv6 address of the GKE cluster.                                                                                                                                                          |
| mqtt_ipv4_address               | IPv4 address of the MQTT service. It's null if enable_external_workers is false. It's only useful in case the workerpool is outside the GKE cluster.                                             |
| mqtt_ipv6_address               | IPv6 address of the MQTT service. It's null if enable_external_workers is false. It's only useful in case the workerpool is outside the GKE cluster.                                             |
| artifact_repository_url         | URL of the Docker artifact repository.                                                                                                                                                           |
| db_database_name                | Internal PostgreSQL db name inside the Cloud SQL instance.                                                                                                                                       |
| db_instance_name                | Name of the database.                                                                                                                                                                            |
| db_root_password                | Database root password.                                                                                                                                                                          |
| db_connection_name              | Connection name of the database connection. Needs to be passed to the Cloud SQL sidecar proxy. See the [official docs](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#proxy). |
| db_private_ip_address           | Private IP address of the database instance.                                                                                                                                                     |
| large_queue_messages_bucket     | Name of the bucket used for storing large queue messages.                                                                                                                                        |
| metadata_bucket                 | Name of the bucket used for storing run metadata.                                                                                                                                                |
| modules_bucket                  | Name of the bucket used for storing Spacelift modules.                                                                                                                                           |
| policy_inputs_bucket            | Name of the bucket used for storing policy inputs.                                                                                                                                               |
| run_logs_bucket                 | Name of the bucket used for storing run logs.                                                                                                                                                    |
| states_bucket                   | Name of the bucket used for storing stack states.                                                                                                                                                |
| uploads_bucket                  | Name of the bucket used for storing user uploads.                                                                                                                                                |
| user_uploaded_workspaces_bucket | Name of the bucket used for storing user uploaded workspaces. This is used for the local preview feature.                                                                                        |
| workspace_bucket                | Name of the bucket used for storing stack workspace data.                                                                                                                                        |
| deliveries_bucket               | Name of the bucket used for storing audit trail delivery data.                                                                                                                                   |
| shell                           | A list of shell variables to export to continue with the install process.                                                                                                                        |

### Examples

#### Default

This deploys a new VPC, an RDS Postres cluster, all the related infrastructure resources, as well as an EKS cluster:

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region = var.aws_region

  # The domain you want to host Spacelift on, for example spacelift.example.com.
  server_domain      = var.server_domain
}
```

### External workers

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region    = var.aws_region
  server_domain = var.server_domain

  # The domain workers should use to connect to the Spacelift MQTT broker. For example mqtt.spacelift.example.com.
  mqtt_broker_domain = var.mqtt_broker_domain
}
```

### Deploy into an existing VPC

```hcl
locals {
  # The name of the EKS cluster that will be created. This needs to be defined up
  # front to allow the VPC subnets to be tagged correctly.
  cluster_name = "spacelift-cluster"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "spacelift-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  # DNS hostnames and DNS support are required for EKS.
  enable_dns_hostnames = true
  enable_dns_support   = true

  # We tag the subnets to let EKS know which subnets to use for running workloads and load balancing.
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region         = var.aws_region
  server_domain      = var.server_domain

  create_vpc         = false
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  # When defining your own VPC, you need to provide the database, server, drain and scheduler
  # security groups. Take a look at https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted/blob/main/modules/network/security_groups.tf
  # for an example of how these should be defined.
  rds_security_group_ids      = [aws_security_group.database_sg.id]
  server_security_group_id    = aws_security_group.server_sg.id
  drain_security_group_id     = aws_security_group.drain_sg.id
  scheduler_security_group_id = aws_security_group.scheduler_sg.id

  eks_cluster_name = local.cluster_name
}
```

## 🚀 Release

We have a [GitHub workflow](./.github/workflows/release.yaml) to automatically create a tag and a release based on the version number in [`.spacelift/config.yml`](./.spacelift/config.yml) file.

When you're ready to release a new version, just simply bump the version number in the config file and open a pull request. Once the pull request is merged, the workflow will create a new release.
