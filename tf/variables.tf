
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"

  validation {
    condition = var.region == "us-west-1"
    error_message = "Please deploy demo cluster to us-west-1 region only."
  }
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
  default     = "demo"
}

variable "enable_xray" {
  description = "Enable AWS X-Ray"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default Tags"
  type        = map(any)
}
