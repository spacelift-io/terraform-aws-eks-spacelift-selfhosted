locals {
  async_jobs_queue_arn      = var.create_sqs ? var.queue_arns["async_jobs"] : ""
  async_jobs_fifo_queue_arn = var.create_sqs ? var.queue_arns["async_jobs_fifo"] : ""
  events_inbox_queue_arn    = var.create_sqs ? var.queue_arns["events_inbox"] : ""
  cronjobs_queue_arn        = var.create_sqs ? var.queue_arns["cronjobs"] : ""
  deadletter_queue_arn      = var.create_sqs ? var.queue_arns["deadletter"] : ""
  deadletter_fifo_queue_arn = var.create_sqs ? var.queue_arns["deadletter_fifo"] : ""
  webhooks_queue_arn        = var.create_sqs ? var.queue_arns["webhooks"] : ""
  iot_queue_arn             = var.create_sqs ? var.queue_arns["iot"] : ""
}