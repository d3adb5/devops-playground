output "bucket_name" {
  description = "Name of the S3 bucket that'll store our backups."
  value       = one(module.backup_bucket.*.s3_bucket_id)
}
