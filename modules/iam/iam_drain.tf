resource "aws_iam_role" "drain" {
  name               = "spacelift-drain-role-${var.unique_suffix}"
  assume_role_policy = module.iam_roles_and_policies.drain.assume_role
}

resource "aws_iam_policy" "drain_role" {
  for_each = module.iam_roles_and_policies.drain.policies

  name   = "${aws_iam_role.drain.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "drain_role" {
  for_each = module.iam_roles_and_policies.drain.policies

  role       = aws_iam_role.drain.name
  policy_arn = aws_iam_policy.drain_role[each.key].arn
}
