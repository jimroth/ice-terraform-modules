resource "aws_iam_role_policy" "ice_bucket_full_access_policy" {
  name = "ice-bucket-full-access-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::${var.work_bucket}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::${var.work_bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "dbr_read_access_policy" {
  name = "dbr-read-access-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::${var.dbr_bucket}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${var.dbr_bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cau_read_access_policy" {
  name = "cau-read-access-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::${var.cau_bucket}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${var.cau_bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "assume_ice_role_policy" {
  name = "assume-ice-role-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::*:role/ice"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_metrics_push_policy" {
  name = "cloudwatch-metrics-push-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DecribeTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#
# Allow all Describe* calls plus ability to stop our instance
#
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:Stop*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#
# Allow all Describe* calls
#
resource "aws_iam_role_policy" "organizations_policy" {
  name = "organizations-policy"
  role = "${aws_iam_role.ice_processor_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "organizations:Describe*",
                "organizations:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ice_processor_role" {
  name = "${var.service_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ice_processor_profile" {
  name = "${var.service_name}-profile"
  role = "${aws_iam_role.ice_processor_role.name}"
}
