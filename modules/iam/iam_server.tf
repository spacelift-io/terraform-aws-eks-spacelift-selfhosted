resource "aws_iam_role" "server" {
  name               = "spacelift-server-role-${var.unique_suffix}"
  assume_role_policy = module.iam_roles_and_policies.server.assume_role
}

resource "aws_iam_policy" "server" {
  for_each = module.iam_roles_and_policies.server.policies

  name   = "${aws_iam_role.server.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "server" {
  for_each = module.iam_roles_and_policies.server.policies

  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.server[each.key].arn
}
