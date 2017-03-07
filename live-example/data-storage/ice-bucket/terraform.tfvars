terragrunt = {
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/data-storage/ice-bucket"
    }
    include {
        path = "${find_in_parent_folders()}"
    }
}

bucket_name = "ice-bucket" # Change this to make it unique
region = "us-east-1"
env = "prod"
env_tag = "Prod"
