terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "shoshone-tfstate"
    key            = "shoshonekey/DevOpsSandbox"
    region         = "us-east-1"
    kms_key_id     = "arn:aws:kms:us-east-1:520291287938:key/4fc9e509-04c4-4881-89e7-46fb49790093"
    dynamodb_table = "shoshone-state-lock"
  }
}

module "vpc_sandbox" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.useast1
  }
}

module "eks_sandbox" {
  source = "../../modules/eks"
  providers = {
    aws = aws.useast1
  }
  vpc_id          = module.vpc_sandbox.vpc_id
  private_subnets = module.vpc_sandbox.private_subnets
}

module "ecr_sandbox" {
  source = "../../modules/ecr"
  providers = {
    aws = aws.useast1
  }
}
