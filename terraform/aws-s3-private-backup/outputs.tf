output "bucket_name" {
  description = "Name of the S3 bucket that'll store our backups."
  value       = one(module.backup_bucket.*.s3_bucket_id)
}

output "oidc_provider_arn" {
  description = "ARN for the OIDC IdP configured for GitHub Actions."
  value       = one(aws_iam_openid_connect_provider.github_actions.*.arn)
}

output "state_readonly_role_arn" {
  description = "ARN for the role that can read the Terraform state."
  value       = one(aws_iam_role.tfstate_readonly_access.*.arn)
}
