terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-reader"
    }
    dependencies {
        paths = ["../../vpc", "../../data-storage/ice-bucket", "../../eip"]
    }
}


# YOUR LIST OF CIDRs FOR SSH AND HTTP ACCESS
ssh_cidrs = []
http_cidrs = []

ssl_creds_dir = "<Path to your SSL Credentials Directory containing ice.crt and ice.key>"
key_name = "YOUR_KEY_PAIR_NAME"
ldap_password = "YOUR_LDAP_ADMIN_PASSWORD"

region = "us-east-1"
env = "prod"
env_tag = "Prod"
tf_state_bucket = "YOUR_TERRAFORM_STATE_BUCKET"
tf_state_region = "us-east-1"
