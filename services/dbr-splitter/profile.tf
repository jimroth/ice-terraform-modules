resource "aws_iam_role_policy" "dbr_full_access_policy" {
  name = "dbr-full-access-policy"
  role = "${aws_iam_role.dbr_splitter_role.id}"

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
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::${var.dbr_bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cost_and_usage_read_access_policy" {
  name = "cost-and_usage-read-access-policy"
  role = "${aws_iam_role.dbr_splitter_role.id}"

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
            "Resource": "arn:aws:s3:::${var.cost_and_usage_bucket}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${var.cost_and_usage_bucket}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "assume_role_policy" {
  name = "assume-role-policy"
  role = "${aws_iam_role.dbr_splitter_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": ${jsonencode(var.assume_role_resources)}
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_metrics_push_policy" {
  name = "cloudwatch-metrics-push-policy"
  role = "${aws_iam_role.dbr_splitter_role.id}"

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

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name = "cloudwatch-logs-policy"
  role = "${aws_iam_role.dbr_splitter_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
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
  role = "${aws_iam_role.dbr_splitter_role.id}"

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

resource "aws_iam_role" "dbr_splitter_role" {
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

resource "aws_iam_instance_profile" "dbr_splitter_profile" {
  name = "${var.service_name}-profile"
  role = "${aws_iam_role.dbr_splitter_role.name}"
}
