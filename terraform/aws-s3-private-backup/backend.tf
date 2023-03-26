terraform {
  backend "s3" {
    region         = "us-west-2"
    bucket         = "d3adb5-private-backup-tfstate"
    key            = "terraform.tfstate"
    dynamodb_table = "d3adb5-private-backup-tfstate"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
