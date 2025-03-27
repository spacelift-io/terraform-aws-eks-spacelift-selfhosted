resource "aws_iam_role" "scheduler" {
  name               = "spacelift-scheduler-role-${var.unique_suffix}"
  description        = "Role used by scheduler"
  assume_role_policy = module.iam_roles_and_policies.scheduler.assume_role
}

resource "aws_iam_policy" "scheduler" {
  for_each = module.iam_roles_and_policies.scheduler.policies

  name   = "${aws_iam_role.scheduler.name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  for_each = module.iam_roles_and_policies.scheduler.policies

  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler[each.key].arn
}
