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
