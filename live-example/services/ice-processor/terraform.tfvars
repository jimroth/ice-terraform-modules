terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-processor"
    }
    dependencies {
        paths = ["../../vpc", "../../data-storage/ice-bucket"]
    }
}

# YOUR CIDRs FOR SSH ACCESS 
cidrs               = []
key_name            = "YOUR_KEY_PAIR_NAME"
dbr_s3_region       = "YOUR_DETAILED_BILLING_REPORT_BUCKET_REGION"
dbr_bucket          = "YOUR_DETAILED_BILLING_REPORT_BUCKET"
account             = "YOUR_AWS_ACCOUNT_NUMBER"

region = "us-east-1"
env = "prod"
env_tag = "Prod"
tf_state_bucket = "YOUR_TERRAFORM_STATE_BUCKET"
tf_state_region = "us-east-1"
