resource "aws_iam_user" "backup" {
  count = terraform.workspace == "default" ? 0 : 1
  name  = "backup"
}

resource "aws_iam_user_policy" "bucket_access" {
  count  = terraform.workspace == "default" ? 0 : 1
  name   = "BackupBucketAccess"
  user   = aws_iam_user.backup[0].name
  policy = data.aws_iam_policy_document.bucket_access[0].json
}

data "aws_iam_policy_document" "bucket_access" {
  count = terraform.workspace == "default" ? 0 : 1

  statement {
    sid       = "AllowListingObjects"
    actions   = ["s3:ListBucket"]
    resources = [module.backup_bucket.s3_bucket_arn]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowReadWriteOnBucket"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.backup_bucket.s3_bucket_arn}/*"]
    effect    = "Allow"
  }
}

#######################################################################
#             OpenID Connect Provider for GitHub Actions              #
#######################################################################

resource "aws_iam_openid_connect_provider" "github_actions" {
  count           = terraform.workspace == "default" ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

resource "aws_iam_role" "tfstate_readonly_access" {
  count              = terraform.workspace == "default" ? 1 : 0
  name               = "PrivateS3BackupTfstateROAccess"
  assume_role_policy = data.aws_iam_policy_document.oidc_trust[0].json
}

resource "aws_iam_role_policy" "state_readonly_access" {
  count  = terraform.workspace == "default" ? 1 : 0
  name   = "StateReadonlyAccess"
  role   = aws_iam_role.tfstate_readonly_access[0].name
  policy = data.aws_iam_policy_document.state_readonly_access[0].json
}

data "aws_iam_policy_document" "oidc_trust" {
  count = terraform.workspace == "default" ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.github_actions[0].url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${aws_iam_openid_connect_provider.github_actions[0].url}:sub"
      values   = ["repo:d3adb5/devops-playground:*"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "state_readonly_access" {
  count = terraform.workspace == "default" ? 1 : 0

  statement {
    sid       = "AllowListingObjects"
    actions   = ["s3:ListBucket"]
    resources = [module.tfstate_backend[0].s3_bucket_arn]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowReadOnBucket"
    actions   = ["s3:GetObject"]
    resources = ["${module.tfstate_backend[0].s3_bucket_arn}/*"]
    effect    = "Allow"
  }

  statement {
    sid = "AllowReadWriteOnDynamoDBTable"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]

    resources = [module.tfstate_backend[0].dynamodb_table_arn]
    effect    = "Allow"
  }
}
