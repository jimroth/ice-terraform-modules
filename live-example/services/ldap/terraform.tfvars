terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ldap"
    }
    dependencies {
        paths = ["../../vpc", "../bastion"]
    }
}

key_name = "YOUR_KEY_PAIR_NAME"
ldap_password = "YOUR_LDAP_ADMIN_PASSWORD"

region = "us-east-1"
env = "prod"
env_tag = "Prod"
tf_state_bucket = "YOUR_TERRAFORM_STATE_BUCKET"
tf_state_region = "us-east-1"
