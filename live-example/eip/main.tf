provider "aws" {
    region = "us-east-1"
}

resource "aws_eip" "ice_eip_us_east_1" {
    vpc = true
}