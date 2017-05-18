terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }
    terraform {
        source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-processor"

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
        paths = ["../../vpc", "../../data-storage/ice-bucket"]
    }
}

# YOUR CIDRs FOR SSH ACCESS 
cidrs               = []
key_name            = "YOUR_KEY_PAIR_NAME"
dbr_s3_region       = "YOUR_DETAILED_BILLING_REPORT_BUCKET_REGION"
dbr_bucket          = "YOUR_DETAILED_BILLING_REPORT_BUCKET"
account             = "YOUR_AWS_ACCOUNT_NUMBER"
