output "ice_eips" {
    value = {
        us-east-1 = "${aws_eip.ice_eip_us_east_1.id}"
    }
}
