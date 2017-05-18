terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-reader"

        extra_arguments "common_vars" {
            required_var_files = [
                "${get_tfvars_dir()}/../../common.tfvars"
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
