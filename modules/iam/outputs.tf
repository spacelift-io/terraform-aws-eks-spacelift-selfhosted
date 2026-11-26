output "server_role_arn" {
  value = aws_iam_role.server.arn
}

output "drain_role_arn" {
  value = aws_iam_role.drain.arn
}

output "vcs_gateway_role_arn" {
  value = aws_iam_role.vcs_gateway.arn
}

output "flows_role_arn" {
  value = one(aws_iam_role.flows[*].arn)
}
