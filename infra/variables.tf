variable "aws_region" {
  type        = string
  description = "AWS default region"
  default     = "ap-southeast-2"
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "ac-msk"
}

variable "environment" {
  type        = string
  description = "environment, e.g. 'nonprod' or 'prod'"
  default     = "nonprod"
}

variable "account_type" {
  type        = string
  description = "AWS Account Type - NonProd or Prod"
  default     = "nonprod"
}
