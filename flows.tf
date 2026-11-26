locals {
  flows_enabled = try(nonsensitive(var.flows != null), var.flows != null)
}

resource "random_uuid" "flows_default_agent_pool_id" {
  count = local.flows_enabled ? 1 : 0

  # We can't do these validations on a variable level, so we'll do it here.
  lifecycle {
    precondition {
      condition     = var.license_token != null && var.license_token != ""
      error_message = "license_token has to be set when flows is set. Flows doesn't start without a license token."
    }

    precondition {
      condition     = var.create_database || try(length(var.flows.database_url), 0) > 0
      error_message = "flows.database_url has to be set when create_database is false. Without it Flows looks for a database on localhost."
    }
  }
}

resource "random_password" "flows_default_agent_pool_token" {
  count = local.flows_enabled ? 1 : 0

  length  = 64
  special = false
  upper   = false
}
