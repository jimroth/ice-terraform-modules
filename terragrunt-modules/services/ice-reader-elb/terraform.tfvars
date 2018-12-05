terragrunt = {
    include {
        path = "${find_in_parent_folders()}"
    }

    dependencies {
        paths = ["../../vpc", "../../data-storage/ice-bucket", "../ice-processor"]
    }
}