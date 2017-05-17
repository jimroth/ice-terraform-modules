resource "aws_iam_role_policy" "iam_read_access_policy" {
  name = "iam-read-access-policy"
  role = "${aws_iam_role.ldap_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_metrics_push_policy" {
  name = "cloudwatch-metrics-push-policy"
  role = "${aws_iam_role.ldap_role.id}"

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

resource "aws_iam_role" "ldap_role" {
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

resource "aws_iam_instance_profile" "ldap_profile" {
  name  = "${var.service_name}-profile"
  role = "${aws_iam_role.ldap_role.name}"
}
