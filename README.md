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

This deploys a new VPC, a new Cloud SQL instance and a GKE cluster

```hcl
module "spacelift" {
  source  = "github.com/spacelift-io/terraform-google-spacelift-selfhosted?ref=v0.0.5"

  region         = var.aws_region
  project        = var.project
  website_domain = var.app_domain
  database_tier  = "db-f1-micro"
  labels         = {"app" = "spacelift"}
}
```

### Deploy a cluster in an existing network

```hcl
resource "google_compute_network" "default" {
  name = "test"
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  name    = "test"
  network = google_compute_network.default.id
  region        = var.aws_region
  ip_cidr_range = "10.0.0.0/16"
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
  secondary_ip_range {
    range_name = "services"
    ip_cidr_range = "192.168.16.0/22"
  }
  secondary_ip_range {
    range_name = "pods"
    ip_cidr_range = "192.168.0.0/20"
  }
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-google-spacelift-selfhosted?ref=v0.0.5"

  region         = var.aws_region
  project        = var.project
  website_domain = var.app_domain
  database_tier  = "db-f1-micro"

  enable_network = false
  network = google_compute_network.default
  subnetwork = google_compute_subnetwork.default
}
```

#### Do not create a VPC and GKE cluster

```hcl
resource "google_compute_network" "default" {
  name = "test"
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_service_account" "gke-node-service-account" {
  account_id = "test-elie"
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-google-spacelift-selfhosted?ref=v0.0.5"

  region         = var.aws_region
  project        = var.project
  website_domain = var.app_domain
  database_tier  = "db-f1-micro"

  enable_gke = false
  enable_network = false
  node_service_account = google_service_account.gke-node-service-account
  network = google_compute_network.default
}
```

#### Do not create DB, VPC and GKE cluster

```hcl
resource "google_service_account" "gke-node-service-account" {
  account_id = "test-elie"
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-google-spacelift-selfhosted?ref=v0.0.5"

  region         = var.aws_region
  project        = var.project
  website_domain = var.app_domain
  database_tier  = "db-f1-micro"

  enable_database      = false
  enable_gke           = false
  enable_network       = false
  node_service_account = google_service_account.gke-node-service-account
}
```

## 🚀 Release

We have a [GitHub workflow](./.github/workflows/release.yaml) to automatically create a tag and a release based on the version number in [`.spacelift/config.yml`](./.spacelift/config.yml) file.

When you're ready to release a new version, just simply bump the version number in the config file and open a pull request. Once the pull request is merged, the workflow will create a new release.
