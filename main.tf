terraform {
  required_version = "1.1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "secret_name" {
  default = "aka4/token"
}
variable "aka4_corp_id" {}
variable "revision" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_iam_role" "aka4_lambda_role" {
  name = "aka4_lambda_role"

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

resource "aws_iam_role_policy" "aka4_lambda_role_policy" {
  name   = "iam_role_policy"
  role   = aws_iam_role.aka4_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Action": [
        "sns:Publish"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "aka4_refresh_lambda" {
  function_name = "aka4_refresh"
  description   = "Akashi のトークンをリフレッシュする関数"
  role          = aws_iam_role.aka4_lambda_role.arn
  package_type  = "Image"
  image_uri     = format("%s:%s", aws_ecr_repository.aka4.repository_url, var.revision)
  image_config {
    command = ["app.LambdaFunction::Handler.refresh"]
  }

  environment {
    variables = {
      CORPORATION_ID = var.aka4_corp_id
      SECRET_ID      = var.secret_name
      TOPIC_ARN      = aws_sns_topic.aka4.arn
    }
  }
}

resource "aws_lambda_function" "aka4_punch_lambda" {
  function_name = "aka4_punch"
  description   = "Akashi で打刻をする関数"
  role          = aws_iam_role.aka4_lambda_role.arn
  package_type  = "Image"
  image_uri     = format("%s:%s", aws_ecr_repository.aka4.repository_url, var.revision)
  image_config {
    command = ["app.LambdaFunction::Handler.punch"]
  }

  environment {
    variables = {
      CORPORATION_ID = var.aka4_corp_id
      SECRET_ID      = var.secret_name
      TOPIC_ARN      = aws_sns_topic.aka4.arn
    }
  }
}

resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "secretsmanagerInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aka4_refresh_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_secretsmanager_secret" "aka4_secret" {
  name        = var.secret_name
  description = "Akashi のトークン"
}

resource "aws_secretsmanager_secret_rotation" "aka4_secret_rotation" {
  secret_id           = aws_secretsmanager_secret.aka4_secret.id
  rotation_lambda_arn = aws_lambda_function.aka4_refresh_lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_sns_topic" "aka4" {
  name = "aka4"
}

resource "aws_ecr_repository" "aka4" {
  name = "aka4"
}
