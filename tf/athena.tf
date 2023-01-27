resource "aws_athena_workgroup" "metric_data" {
  name = "${var.cluster_name}-metric-data"
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    engine_version {
      selected_engine_version = "AUTO"
    }
    result_configuration {
      output_location = "s3://${aws_s3_bucket.metric_data_athena_bucket.id}/output/"
    }
  }
  force_destroy = true
}

locals {
  updated_bucket_name = (replace("${aws_s3_bucket.metric_data_athena_bucket.id}", "-", "_"))
}

resource "aws_athena_named_query" "select_all_metric_data" {
  name     = "select_all_metric_data"
  workgroup = aws_athena_workgroup.metric_data.id
  database = aws_glue_catalog_database.aws_glue_metric_database.name
  query    = "SELECT * FROM \"${aws_glue_catalog_database.aws_glue_metric_database.name}\".\"${aws_glue_catalog_table.metric_table.name}\""
}

resource "aws_ssm_parameter" "athena_workgroup_ssm" {
  name  = "${var.cluster_name}AthenaWorkGroup"
  description = "Athena WorkGroup SSM Parameter"
  type  = "String"
  value = aws_athena_workgroup.metric_data.name
}
