locals {
  async_jobs_queue_url      = var.create_sqs ? var.queue_urls["async_jobs"] : ""
  async_jobs_fifo_queue_url = var.create_sqs ? var.queue_urls["async_jobs_fifo"] : ""
  events_inbox_queue_url    = var.create_sqs ? var.queue_urls["events_inbox"] : ""
  cronjobs_queue_url        = var.create_sqs ? var.queue_urls["cronjobs"] : ""
  deadletter_queue_url      = var.create_sqs ? var.queue_urls["deadletter"] : ""
  deadletter_fifo_queue_url = var.create_sqs ? var.queue_urls["deadletter_fifo"] : ""
  webhooks_queue_url        = var.create_sqs ? var.queue_urls["webhooks"] : ""
  iot_queue_url             = var.create_sqs ? var.queue_urls["iot"] : ""
}