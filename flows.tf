locals {
  # The object can carry sensitive values, which makes this check sensitive too.
  # Whether Flows is deployed is not a secret, and count needs a plain value.
  flows_enabled = nonsensitive(var.flows != null)
}

resource "random_uuid" "flows_default_agent_pool_id" {
  count = local.flows_enabled ? 1 : 0
}

resource "random_password" "flows_default_agent_pool_token" {
  count = local.flows_enabled ? 1 : 0

  length  = 64
  special = false
  upper   = false
}
