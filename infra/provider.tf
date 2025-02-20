provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    encrypt = true
    bucket  = "ac-shopping-tf-state"
    key     = "msk.tfstate"
    region  = "ap-southeast-2"
  }
  required_providers {
  }

}
