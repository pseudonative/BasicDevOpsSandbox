provider "aws" {
  alias  = "useast1"
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::520291287938:role/ProdFullAccess"
    session_name = "Terraform-ProdUpdate"
  }
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
