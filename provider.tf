terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.50" }
  }

  backend "s3" {
    bucket = "k8s-state99"               # your existing S3 bucket
    key    = "tfstate/ec2-infra.tfstate" # path inside bucket
    region = "us-east-1"                  # bucket's region
  }
}

provider "aws" {
  region = var.region
}
