resource "aws_iam_role" "execution_role" {
  name               = "${var.task_definition_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = { Name = "${var.task_definition_name}-execution-role" }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ssm_access" {
  count  = length(var.ssm_parameter_arns) > 0 ? 1 : 0
  name   = "${var.task_definition_name}-ssm-access"
  role   = aws_iam_role.execution_role.id
  policy = data.aws_iam_policy_document.ssm_access.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt"
    ]

    resources = var.ssm_parameter_arns
  }
}
