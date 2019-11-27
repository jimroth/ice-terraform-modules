terraform {
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
