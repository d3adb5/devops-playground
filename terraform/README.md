# Terraform Playground

This is a simple Terraform playground to test out Terraform configurations,
modules, and providers. The configuration in this repository won't be used for
real infrastructure, by which I mean there won't be CD pipelines deploying these
to PaaS / IaaS providers. They might be used locally, but not in "production".

## AWS S3 Private Backup

The `aws-s3-private-backup` directory contains a Terraform configuration that
makes use of [binbashar/terraform-aws-tfstate-backend][binbashar] for the
backend supporting infrastructure, and
[terraform-aws-modules/terraform-aws-s3-bucket][s3bucket] for the S3 bucket
that will store our backups.

Its purpose is to create a private S3 bucket that can be used to store personal
backups of files we don't want to lose. Though I'm pretty sure nowadays
[rclone][rclone] can help you create the S3 bucket itself, I thought it was
best to do it through Terraform so we can keep track of state and have more
flexibility with configuring the bucket.

With how it is set up, objects in the bucket will be put immediately in the
Intelligent-Tiering storage class, being moved into the Archive Access Tier if
the object hasn't been accessed in 120 days, and Deep Archive Access Tier if it
hasn't been accessed in 180 days.

**Note:** I've committed the `backend.tf` file that I personally use. Remove
that if you wish to try out this Terraform configuration.

[binbashar]: https://github.com/binbashar/terraform-aws-tfstate-backend
[s3bucket]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket
[rclone]: https://rclone.org/
