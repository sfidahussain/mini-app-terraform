terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Default region specified as us-east-1
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}