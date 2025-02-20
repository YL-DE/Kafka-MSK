variable "vpc_name" {
  type        = string
  default     = "ac-shopping-vpc"
  description = "ac-shopping vpc"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = { "team" : "DE" }
}
