# Event processing for starting the dbr-splitter instance from a CloudWatch schedule

resource "aws_lambda_alias" "start_dbr_splitter_func_alias" {
  name             = "startDbrSplitterFuncLatest"
  description      = "latest version of function to start the dbr splitter instance"
  function_name    = "${aws_lambda_function.start_dbr_splitter_lambda.arn}"
  function_version = "$LATEST"
}

resource "aws_iam_role_policy" "instance_start_policy" {
  name = "instance-start-policy"
  role = "${aws_iam_role.start_dbr_splitter_lambda_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Start*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "start_dbr_splitter_lambda_role" {
  name = "start-${var.service_name}-lambda-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "archive_file" "start_dbr_splitter_lambda_code" {
  type        = "zip"
  source_file = "${path.module}/start-instance.py"
  output_path = "${path.module}/.terraform/archive_files/start-instance.zip"
}

resource "aws_lambda_function" "start_dbr_splitter_lambda" {
  filename         = "${data.archive_file.start_dbr_splitter_lambda_code.output_path}"
  function_name    = "${var.service_name}-start-instance"
  role             = "${aws_iam_role.start_dbr_splitter_lambda_role.arn}"
  runtime          = "python2.7"
  handler          = "start-instance.lambda_handler"
  source_code_hash = "${data.archive_file.start_dbr_splitter_lambda_code.output_base64sha256}"
  timeout          = "10"

  environment {
    variables = {
      az = "${aws_instance.dbr_splitter.availability_zone}"
      id = "${aws_instance.dbr_splitter.id}"
    }
  }
}

resource "aws_cloudwatch_event_target" "start_dbr_splitter_lambda_target" {
  rule = "${aws_cloudwatch_event_rule.start_dbr_splitter.name}"
  arn  = "${aws_lambda_function.start_dbr_splitter_lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "start_dbr_splitter" {
  name = "start-dbr-splitter"

  # Run every 6 hours
  schedule_expression = "cron(0 0/6 * * ? *)"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_dbr_splitter_lambda.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.start_dbr_splitter.arn}"
}
