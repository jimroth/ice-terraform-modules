# Event processing for starting the ice-processor instance when a new billing file is dropped
# into the S3 bucket.

provider "aws" {
  alias  = "dbr_region"
  region = "${var.dbr_s3_region}"
}

resource "aws_lambda_permission" "allow_s3" {
  provider       = "aws.dbr_region"
  statement_id   = "AllowExecutionFromS3"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.start_ice_processor_lambda.arn}"
  principal      = "s3.amazonaws.com"
  source_account = "${var.account}"
  source_arn     = "arn:aws:s3:::${var.dbr_bucket}"
  qualifier      = "${aws_lambda_alias.start_ice_processor_func_alias.name}"
}

resource "aws_lambda_alias" "start_ice_processor_func_alias" {
  provider         = "aws.dbr_region"
  name             = "startIceProcessorFuncLatest"
  description      = "latest version of function to start the ice processor instance"
  function_name    = "${aws_lambda_function.start_ice_processor_lambda.arn}"
  function_version = "$LATEST"
}

resource "aws_iam_role_policy" "instance_start_policy" {
  name = "instance-start-policy"
  role = "${aws_iam_role.start_ice_processor_role.id}"

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

resource "aws_iam_role" "start_ice_processor_role" {
  name = "start-${var.service_name}-role"

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

data "archive_file" "start_ice_lambda_code" {
  type        = "zip"
  source_file = "${path.module}/start-instance.py"
  output_path = "${path.module}/.terraform/archive_files/start-instance.zip"
}

resource "aws_lambda_function" "start_ice_processor_lambda" {
  provider         = "aws.dbr_region"
  filename         = "${data.archive_file.start_ice_lambda_code.output_path}"
  function_name    = "${var.service_name}-start-instance"
  role             = "${aws_iam_role.start_ice_processor_role.arn}"
  runtime          = "python2.7"
  handler          = "start-instance.lambda_handler"
  source_code_hash = "${data.archive_file.start_ice_lambda_code.output_base64sha256}"
  timeout          = "10"

  environment {
    variables = {
      az = "${aws_instance.ice_processor.availability_zone}"
      id = "${aws_instance.ice_processor.id}"
    }
  }
}

resource "aws_s3_bucket_notification" "dbr_bucket_notification" {
  provider = "aws.dbr_region"
  bucket   = "${var.dbr_bucket}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_alias.start_ice_processor_func_alias.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip"
  }
}
