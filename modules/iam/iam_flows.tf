resource "aws_iam_role" "flows" {
  count = var.flows == null ? 0 : 1

  name               = "spacelift-flows-role-${var.unique_suffix}"
  description        = "Role used by Spacelift Flows"
  assume_role_policy = module.iam_roles_and_policies.flows.assume_role
}

resource "aws_iam_policy" "flows" {
  count = var.flows == null ? 0 : 1

  name   = "${aws_iam_role.flows[0].name}-FLOWS"
  policy = module.iam_roles_and_policies.flows.policies["FLOWS"]
}

resource "aws_iam_role_policy_attachment" "flows" {
  count = var.flows == null ? 0 : 1

  role       = aws_iam_role.flows[0].name
  policy_arn = aws_iam_policy.flows[0].arn
}
