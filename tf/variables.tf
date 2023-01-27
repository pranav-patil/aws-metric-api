
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
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
