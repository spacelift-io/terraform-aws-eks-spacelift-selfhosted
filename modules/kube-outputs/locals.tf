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