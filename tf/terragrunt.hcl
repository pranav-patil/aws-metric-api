# vim: set syntax=terraform:

terraform_version_constraint  = "~> 0.15.0"
terragrunt_version_constraint = ">= 0.31"

include {
  path = find_in_parent_folders()
}

locals {
  toplevel = read_terragrunt_config(find_in_parent_folders())
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.toplevel.inputs.cluster_name}-aws-metric-infra"
    key            = "${path_relative_to_include}/terraform.tfstate"
    region         = local.toplevel.inputs.region
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
    s3_bucket_tags = local.toplevel.inputs.default_tags
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}
