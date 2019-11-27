include {
    path = find_in_parent_folders()
}

terraform {
    source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-processor"

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

inputs = {
    # YOUR CIDRs FOR SSH ACCESS 
    cidrs               = []
    key_name            = "YOUR_KEY_PAIR_NAME"
    dbr_s3_region       = "YOUR_DBR_BUCKET_REGION"
    dbr_bucket          = "YOUR_DBR_BUCKET"
    cau_s3_region       = "YOUR_COST_AND_USAGE_REPORT_BUCKET_REGION"
    cau_bucket          = "YOUR_COST_AND_USAGE_REPORT_BUCKET"
    wake_on_sns         = "YOUR_SNS_ARN_FOR_UPDATE_MESSAGES"
    account             = "YOUR_AWS_ACCOUNT_NUMBER"
    instance_type       = "YOUR_EC2_INSTANCE_TYPE"
    ebs_volume_size     = "YOUR_EBS_VOLUME_SIZE_IN_GB"
}
