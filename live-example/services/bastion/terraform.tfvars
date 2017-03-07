terragrunt {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/bastion"
    }
    dependencies {
        paths = ["../../vpc"]
    }
}

# YOUR CIDRs FOR SSH ACCESS
cidrs    = []
key_name = "YOUR_KEY_PAIR_NAME"
region = "us-east-1"
env = "prod"
env_tag = "Prod"
tf_state_bucket = "YOUR_TERRAFORM_STATE_BUCKET"
tf_state_region = "us-east-1"
