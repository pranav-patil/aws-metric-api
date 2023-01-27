#
# Terraform Configuration for the Monitoring
# - VPC and Peering connections
#

terraform {
  backend "s3" {
    encrypt = true
  }
}

# Get the available Availability Zones from AWS
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
