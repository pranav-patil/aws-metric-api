variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "emprovise-demo"
}

variable "enable_crawler" {
  description = "Enable Glue Crawler"
  type        = bool
  default     = true
}

variable "env" {
  description = "Environment"
  default     = "rnd"
}

variable "stack" {
  description = "Infrastructure Stack"
  default     = "develop"
}

variable "stage" {
  description = "Stage"
  default     = "develop"
}

variable "user" {
  description = "User making infrastructure changes"
  type        = string
}

variable "revision" {
  description = "Source code revision of infra-rnd, i.e. git commit"
  type        = string
}

variable "keypair" {
  description = "Key Pair for Mock and Bastion EC2s"
  type        = string
}

variable "default_execution_role" {
  description = "Default IAM Role name for Task Execution"
  type        = string
}

variable "default_task_role" {
  description = "Default IAM Role name for Tasks"
  type        = string
}

variable "bastion_iam_role" {
  description = "IAM role used by bastion host"
  type        = string
}

variable "lifetime" {
  description = "Lifetime of cluster in days"
  type        = number
  default     = 1
}

variable "keep_alive" {
  description = "Keep cluster alive regardless of age"
  type        = bool
  default     = false
}

variable "rnd_app_vpc_cidr" {
  description = "Application VPC CIDR"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_xray" {
  description = "Enable AWS X-Ray"
  type        = bool
  default     = false
}

variable "allow_access_from" {
  description = "Allow access to cluster and hosts from CIDRs"
  type        = list(string)
}
