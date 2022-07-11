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
  region = var.context.aws_region
  shared_credentials_file = var.context.aws_credentials_file
  profile = var.context.aws_profile
}

