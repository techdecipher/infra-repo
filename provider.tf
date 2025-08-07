terraform {
  backend "s3" {
    bucket         = "k8s-state99"
    key            = "tfstate/eks-cluster.tfstate"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
