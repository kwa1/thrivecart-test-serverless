terraform {
  backend "s3" {
    bucket  = "thrivecart-terraform-state-bucket"
    key     = "terraform/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
provider "aws" {
  region = var.region
  default_tags {
    tags = local.common_tags
  }
}
