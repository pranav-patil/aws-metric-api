# vim: set syntax=terraform:

terraform_version_constraint  = "~> 1.1.4"
terragrunt_version_constraint = ">= 0.31"

locals {
  stage        = get_env("STAGE", "demo")
  user         = get_env("USER", "test_user")
  region       = get_env("REGION", "us-west-1")
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "aws-metric-terraform-${local.stage}-${local.region}"
    key            = "tf_remote_states/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}

inputs = merge(
  {
    stage = local.stage
  },
  {
    user = local.user,
    default_tags =  {
      Stage       = local.stage
      CreatedBy   = local.user
      Environment = "demo"
    }
  }
)

terraform {

  before_hook "Environment" {
    commands = ["init", "plan", "apply", "destroy"]
    execute  = ["echo", "STAGE=${local.stage}, AWS_REGION=${local.region}"]
  }

  extra_arguments "init" {
    commands = ["init"]
    arguments = [
      "-upgrade=true",
      "-reconfigure",
    ]
  }

  extra_arguments "plan" {
    commands = ["plan"]
    arguments = [
      "-out=tfplan",
    ]
  }
}
