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
      lock_table = "terraform-lock-table"
    }
  }

  terraform = {
    extra_arguments "globals" {
      arguments = [
        "-var-file=${find_in_parent_folders()}",
      ]

      commands = [
        "apply",
        "plan",
        "destroy",
        "import",
        "push",
        "refresh",
      ]
    }
  }

  terraform {
    # Force Terraform to keep trying to acquire a lock for up to 20 minutes if someone else already has the lock
    extra_arguments "retry_lock" {
      commands = [
        "init",
        "apply",
        "refresh",
        "import",
        "plan",
        "taint",
        "untaint"
      ]

      arguments = [
        "-lock-timeout=20m"
      ]
    }
  }
}
