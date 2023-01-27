# Provider configuration

provider "aws" {
  region = var.region

  ignore_tags {
    keys = ["CreatedBy"]
  }

  default_tags {
    tags = var.default_tags
  }
}

provider "aws" {
  region = "us-west-1"
  alias  = "us-west-1"

  ignore_tags {
    keys = ["CreatedBy"]
  }

  default_tags {
    tags = var.default_tags
  }
}
