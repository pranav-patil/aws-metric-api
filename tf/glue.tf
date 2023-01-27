resource "aws_glue_catalog_database" "aws_glue_metric_database" {
  name        = "${replace(var.cluster_name, "-", "_")}_metric_database"
  description = "Catalog Database for metrics from applications"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
}

resource "aws_glue_catalog_table" "metric_table" {
  name          = "${replace(var.cluster_name, "-", "_")}_metric_table"
  database_name = aws_glue_catalog_database.aws_glue_metric_database.name
  description   = "metrics from applications"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                    = "TRUE"
    classification              = "json"
    compressionType             = "None"
    typeOfData                  = "file"
    "projection.enabled"        = true
    "projection.year.type"      = "enum"
    "projection.year.values"    = "2022"
    "projection.month.type"     = "enum"
    "projection.month.values"   = "08"
    "projection.day.type"       = "enum"
    "projection.day.values"     = "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31"
    "storage.location.template" = "s3://${aws_s3_bucket.metric_data_bucket.id}/metrics/year=${"$"}{year}/month=${"$"}{month}/day=${"$"}{day}"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.metric_data_bucket.id}/metrics/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "${var.cluster_name}-metric-data"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
        "key"                  = "appname,instance_id,ts"
      }
    }
    columns {
      name    = "version"
      type    = "int"
      comment = "version number for the message"
    }
    columns {
      name    = "instance_id"
      type    = "string"
      comment = "instance id associated with the application server"
    }
    columns {
      name    = "ts"
      type    = "string"
      comment = "timestamp"
    }
    columns {
      name    = "appname"
      type    = "string"
      comment = "application name"
    }
    columns {
      name    = "message"
      type    = "string"
      comment = "Application Message"
    }
    columns {
      name    = "user"
      type    = "string"
      comment = "user id"
    }
    columns {
      name    = "status"
      type    = "string"
      comment = "access status"
    }
    columns {
      name    = "type"
      type    = "string"
      comment = "access type"
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_glue_catalog_database.aws_glue_metric_database
  ]
}

# Athena works with the table created by crawler??
resource "aws_glue_crawler" "metric-data-crawler" {
  count         = var.enable_crawler ? 1 : 0
  database_name = aws_glue_catalog_database.aws_glue_metric_database.name
  name          = "${var.cluster_name}-metric-data-crawler"
  description   = "Crawler for metric data from applications"
  role          = aws_iam_role.glue_service_role.arn
  schedule      = "cron(0/20 * * * ? *)"
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  s3_target {
    path = "s3://${var.cluster_name}-metric-data-bucket"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
  lineage_configuration {
    crawler_lineage_settings = "ENABLE"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
  depends_on = [
    aws_glue_catalog_database.aws_glue_metric_database
  ]
}
