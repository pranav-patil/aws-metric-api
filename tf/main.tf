data "aws_caller_identity" "current" {}

locals {
  tags = var.default_tags
}

terraform {
  backend "s3" {}
}
