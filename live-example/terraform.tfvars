terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"

    config {
      encrypt = true
      bucket  = "[YOUR_STATE_BUCKET_NAME_HERE]"
      key     = "global/${path_relative_to_include()}/terraform.tfstate"
      region  = "us-east-1"

      # Tell Terraform to do locking using DynamoDB. Terragrunt will automatically create this table for you if
      # it doesn't already exist.
      dynamodb_table = "terraform-lock-table"
    }
  }
}
