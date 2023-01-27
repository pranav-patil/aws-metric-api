
resource "aws_kinesis_firehose_delivery_stream" "audit_logs_firehose" {
  name        = "network-security-${var.cluster_name}-audit-logs-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.kinesis_firehose_stream_role.arn
    bucket_arn          = aws_s3_bucket.metric_data_athena_bucket.arn
    buffer_size         = 64
    buffer_interval     = 60
    s3_backup_mode      = "Enabled"
    prefix              = "auditlogs/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "firehose-errors/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"

    s3_backup_configuration {
      role_arn   = aws_iam_role.kinesis_firehose_stream_role.arn
      bucket_arn = aws_s3_bucket.audit_logs_backup_bucket.arn
      prefix     = "backup"

      cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
        log_stream_name = aws_cloudwatch_log_stream.delivery_stream_logging_stream.name
      }
    }

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
      log_stream_name = aws_cloudwatch_log_stream.delivery_stream_logging_stream.name
    }
    #parquet creation based on glue tables
    data_format_conversion_configuration {
      enabled = "true"
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.aws_glue_metric_database.name
        table_name    = aws_glue_catalog_table.audit_logs_table.name
        role_arn      = aws_iam_role.kinesis_firehose_stream_role.arn
        region        = var.region
      }
    }
  }
  depends_on = [
    aws_glue_catalog_table.audit_logs_table
  ]
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/${var.cluster_name}"
}

resource "aws_cloudwatch_log_stream" "delivery_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "Destination"
}


resource "aws_cloudwatch_log_stream" "backup_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "Backup"
}
