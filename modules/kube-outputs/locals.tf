# Deploy
locals {
  use_sqs      = var.create_sqs || var.sqs_queue_names_override != null
  queue_source = var.sqs_queue_names_override != null ? var.sqs_queue_names_override : var.sqs_queue_urls_generated

  async_jobs_queue_url      = local.use_sqs ? local.queue_source["async_jobs"] : ""
  async_jobs_fifo_queue_url = local.use_sqs ? local.queue_source["async_jobs_fifo"] : ""
  events_inbox_queue_url    = local.use_sqs ? local.queue_source["events_inbox"] : ""
  cronjobs_queue_url        = local.use_sqs ? local.queue_source["cronjobs"] : ""
  deadletter_queue_url      = local.use_sqs ? local.queue_source["deadletter"] : ""
  deadletter_fifo_queue_url = local.use_sqs ? local.queue_source["deadletter_fifo"] : ""
  webhooks_queue_url        = local.use_sqs ? local.queue_source["webhooks"] : ""
  iot_queue_url             = local.use_sqs ? local.queue_source["iot"] : ""
}

# Flows
locals {
  flows_enabled = var.flows != null

  # Null when the image comes from the Spacelift registry, and then the chart's default applies.
  # The chart takes the registry and the repository separately, an ECR URL has both.
  flows_ecr_repository_url = var.spacelift_registry_pull_secret_name == null ? try(var.flows.ecr_repository_url, null) : null
  flows_image_registry     = local.flows_ecr_repository_url == null ? null : split("/", local.flows_ecr_repository_url)[0]
  flows_image_repository   = local.flows_ecr_repository_url == null ? null : trimprefix(local.flows_ecr_repository_url, "${local.flows_image_registry}/")

  # What Spacelift needs to know about Flows. It goes into the Spacelift secret.
  flows_config = !local.flows_enabled ? "" : jsonencode({
    (var.flows.domain) = {
      redirect_url = "https://${var.flows.domain}"
      api_url      = "https://${var.flows.domain}"
    }
  })

  # What the module sets in the Flows config file.
  flows_base_config = !local.flows_enabled ? null : {
    appDomain   = var.flows.domain
    databaseUrl = var.flows_secrets.database_url
    objectStorage = {
      s3 = {
        bucket = var.flows.bucket_name
        region = var.aws_region
      }
    }
    defaultAgentPool = {
      id    = var.flows.agent_pool_id
      token = var.flows_secrets.agent_pool_token
    }
    selfHosted = {
      organizationName = var.flows.organization_name
      adminEmail       = var.flows.admin_email
      adminPassword    = var.flows_secrets.admin_password
      licenseToken     = var.license_token != null ? var.license_token : ""
    }
    server = {
      publicPort   = 8080
      internalPort = 8080
    }
    spaceliftInstances = jsonencode({ (var.server_domain) = {} })
  }

  # It sits with the secrets because it can carry things like an SMTP password. merge() skips a null.
  flows_extra_config = merge({}, try(var.flows_secrets.extra_config, null))

  # A section set on both sides is merged, so that adding a key to one the module writes (like server)
  # keeps the rest of it. Everything else in extra_config is taken as it is.
  flows_app_config = !local.flows_enabled ? null : merge(local.flows_base_config, local.flows_extra_config, {
    for key, value in local.flows_extra_config : key => merge(local.flows_base_config[key], value)
    if can(merge(local.flows_base_config[key], value))
  })

  # Flows reads its settings from a config.yaml in a Secret, not from environment variables.
  flows_secret = !local.flows_enabled ? "" : join("", ["---\n", yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "spacelift-flows-secret"
      namespace = var.k8s_namespace
    }
    type = "Opaque"
    stringData = {
      "config.yaml" = yamlencode(local.flows_app_config)
    }
  })])
}
