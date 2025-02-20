provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    encrypt = true
    bucket  = "ac-shopping-tf-state"
    key     = "vpc.tfstate"
    region  = "ap-southeast-2"
  }

  required_providers {
    # newrelic = {
    #   source  = "newrelic/newrelic"
    #   version = "2.22.1"
    # }
  }
}

# provider "newrelic" {
# }
