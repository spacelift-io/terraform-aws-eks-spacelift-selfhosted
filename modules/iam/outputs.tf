output "server_role_arn" {
  value = aws_iam_role.server.arn
}

output "drain_role_arn" {
  value = aws_iam_role.drain.arn
}

output "scheduler_role_arn" {
  value = aws_iam_role.scheduler.arn
}
