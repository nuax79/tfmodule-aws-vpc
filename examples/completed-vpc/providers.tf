terraform {

  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.20"
    }
  }

}

provider "aws" {
  region  = var.context.aws_region
  profile = var.context.aws_profile
  shared_credentials_file = var.context.aws_credentials_file
}

