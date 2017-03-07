terragrunt {
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/vpc"
    }
    include {
        path = "${find_in_parent_folders()}"
    }
}

region = "us-east-1"
env = "prod"
env_tag = "Prod"
