terraform {
    source = "github.com/jimroth/ice-terraform-modules//terragrunt-modules/data-storage/ice-bucket"

    extra_arguments "common_vars" {
        commands = [
            "apply",
            "plan",
            "destroy",
            "import",
            "push",
            "refresh",
        ]

        arguments = [
            "-var-file=${get_terragrunt_dir()}/../../common.tfvars"
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
include {
    path = find_in_parent_folders()
}

inputs = {
    bucket_name = "YOUR_WORK_BUCKET_NAME"
}

