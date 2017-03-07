terragrunt = {
  # Configure Terragrunt to use DynamoDB for locking
  lock {
    backend = "dynamodb"

    config {
      state_file_id = "global/${path_relative_to_include()}"
    }
  }

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"

    config {
      encrypt = "true"
      bucket  = "[YOUR_STATE_BUCKET_NAME_HERE]"
      key     = "global/${path_relative_to_include()}/terraform.tfstate"
      region  = "us-east-1"
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
}
