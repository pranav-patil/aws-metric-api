
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sls_deploy_assume_role" {
 statement {
   effect = "Allow"
   actions = ["sts:AssumeRole"]

   principals {
     type        = "AWS"
     identifiers = [
       "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
     ]
   }

   principals {
     type        = "Service"
     identifiers = [
       "cloudformation.amazonaws.com",
       "lambda.amazonaws.com",
       "states.amazonaws.com"
     ]
   }
 }
}

resource "aws_iam_role" "sls_deploy" {
  name = "MetricRoleForServerlessDeploy"
  description = "Role used to deploy Serverless applications"
  assume_role_policy = data.aws_iam_policy_document.sls_deploy_assume_role.json
}

resource "aws_iam_role_policy" "sls_deploy" {
  name = "Deploy"
  role = aws_iam_role.sls_deploy.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "Write",
        "Effect": "Allow",
        "Action": [
          "apigateway:*",
          "cloudformation:*",
          "cloudwatch:*",
          "dynamodb:*",
          "events:*",
          "iam:PassRole",
          "lambda:*",
          "logs:*",
          "s3:*",
          "sns:*",
          "sqs:*",
          "ssm:*",
          "states:*",
          "xray:*"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Read",
        "Effect": "Allow",
        "Action": [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "ec2:DeleteNetworkInterface*",
        ],
        "Resource": "*"
      },
      {
        "Sid": "KMS",
        "Effect": "Allow",
        "Action": [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:RetireGrant",
          "kms:PutKeyPolicy"
        ],
        "Resource": "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Sid": "SecretsManager",
        "Effect": "Allow",
        "Action": [
          "secretmanager:Describe*",
          "secretmanager:Get*",
          "secretmanager:List*",
          "secretmanager:Create*",
          "secretmanager:Tag*",
          "secretmanager:Put*"
        ],
        "Resource": "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.sls_deploy.arn
      ]
    }
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "health_events_lambda_role" {
  name                 = "health_events_role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "health_events_lambda_policy" {
  name   = "health_events_role_policy"
  role   = aws_iam_role.health_events_lambda_role.name
#  policy = data.aws_iam_policy_document.prometheus_query_iam_policy.json
  policy = jsonencode({
    # tfsec:ignore:aws-iam-no-policy-wildcards
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AssumeRolesInOtherAccounts",
        "Effect" : "Allow",
        "Action" : ["sts:AssumeRole"],
        "Resource" : "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "cloudwatch_document" {
  statement {
    actions = [
      "cloudwatch:*",
      "logs:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "health_events_lambda_cloudwatch_policy" {
  name   = "health_events_cloudwatch_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.cloudwatch_document.json
}

data "aws_iam_policy_document" "secretmanager_document" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "health_events_lambda_secrets_policy" {
  name   = "health_events_secrets_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.secretmanager_document.json
}

data "aws_iam_policy_document" "metric_alert_sns_document" {
  statement {
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
      "sns:Subscribe"
    ]
    resources = [
      "arn:aws:sns:*:*:*-alert-sns-topic*"
    ]
  }
}

resource "aws_iam_role_policy" "health_events_lambda_sns_policy" {
  name   = "health_events_lambda_sns_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.metric_alert_sns_document.json
}

data "aws_iam_policy_document" "xray_document" {
  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "health_events_lambda_xray_policy" {
  name   = "health_events_xray_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.xray_document.json
}

data "aws_iam_policy" "redshift_data_policy" {
  name = "AmazonRedshiftDataFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_redshift_data_policy" {
  role       = aws_iam_role.health_events_lambda_role.name
  policy_arn = data.aws_iam_policy.redshift_data_policy.arn
}

data "aws_iam_policy_document" "lambda_kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:ListAliases",
      "kms:CreateGrant",
      "kms:Encrypt"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "health_events_lambda_kms_policy" {
  name   = "health_events_kms_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.lambda_kms.json
}

data "aws_iam_policy_document" "ssm_read_access_policy_document" {
  statement {
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "health_events_lambda_ssm_policy" {
  name   = "health_events_ssm_policy"
  role   = aws_iam_role.health_events_lambda_role.name
  policy = data.aws_iam_policy_document.ssm_read_access_policy_document.json
}

data "aws_iam_policy_document" "kinesis_firehose_stream_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.metric_data_athena_bucket.arn,
      "${aws_s3_bucket.metric_data_athena_bucket.arn}/*",
      aws_s3_bucket.audit_logs_backup_bucket.arn,
      "${aws_s3_bucket.audit_logs_backup_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "kinesis_firehose_access_glue_assume_policy" {
  statement {
    effect    = "Allow"
    actions   = ["glue:GetTableVersions"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "kinesis_firehose_stream_role" {
  name                 = "${var.cluster_name}-kinesis_firehose_stream_role"
  assume_role_policy   = data.aws_iam_policy_document.kinesis_firehose_stream_assume_role.json
}


resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  name   = "${var.cluster_name}-kinesis_firehose_access_bucket_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}

resource "aws_iam_role_policy" "kinesis_firehose_access_glue_policy" {
  name   = "${var.cluster_name}-kinesis_firehose_access_glue_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_glue_assume_policy.json
}



data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_s3_bucket_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.metric_data_athena_bucket.arn,
      "${aws_s3_bucket.metric_data_athena_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "glue_service_role" {
  name                 = "${var.cluster_name}-AWSGlueServiceRole-audit-logs"
  assume_role_policy   = data.aws_iam_policy_document.glue_assume_role.json
}


resource "aws_iam_role_policy" "glue_s3_policy" {
  name   = "glue_s3_policy"
  role   = aws_iam_role.glue_service_role.name
  policy = data.aws_iam_policy_document.glue_s3_bucket_assume_policy.json
}


data "aws_iam_policy" "glue_aws_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
resource "aws_iam_role_policy_attachment" "aws-glue-role-policy-attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = data.aws_iam_policy.glue_aws_policy.arn
}

