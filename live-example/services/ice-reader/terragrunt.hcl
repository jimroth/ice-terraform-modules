include {
    path = find_in_parent_folders()
}

terraform {
    source = "git::git@github.com:jimroth/ice-terraform-modules//terragrunt-modules/services/ice-reader-elb"

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

inputs = {
    # YOUR LIST OF CIDRs FOR SSH AND HTTP ACCESS
    ssh_cidrs = []
    http_cidrs = []

    elb_subnet_cidr = "YOUR_ELB_SUBNET_CIDR"

    key_name = "YOUR_KEY_PAIR_NAME"
    instance_type       = "YOUR_EC2_INSTANCE_TYPE"
    vouch_config_file   = "config.yml"
    hostname            = "YOUR_READER_HOSTNAME"
    client_secrets      = "YOUR_SECRETS_ID_FROM_SECRETS_MANAGER"
    health_check        = "HTTP:8000/"
    ebs_volume_size     = "EBS_VOLUME_SIZE_IN_GB"
    elb_subnets = [YOUR_ELB_SUBNETS]
    ssl_certificate_id  = "YOUR_SSL_CERTIFICATE_ARN"
}
