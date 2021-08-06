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

resource "aws_dynamodb_table" "dynamodb-petstore-table" {
  name           = "dynamoDB-Petstore"
  hash_key         = "petId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "petId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "dynamodb-petstore"
    Environment = "test"
  }
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "security_groups" {
  source         = "./security-groups"
  name           = var.name
  vpc_id         = module.vpc.id
  environment    = var.environment
}

module "gateway" {
  source             = "./gateway"
  vpc_id             = module.vpc.id
  subnets            = module.vpc.private_subnets
  security_groups = [module.security_groups.allow_fargate]
}

module "ecs" {
  source             = "./ecs"
  security_groups = [module.security_groups.allow_fargate]
  subnets             = module.vpc.public_subnets
  aws_dynamodb_table_arn = aws_dynamodb_table.dynamodb-petstore-table.arn
  aws_dynamodb_table_name = aws_dynamodb_table.dynamodb-petstore-table.name
  registry_arn =   module.gateway.service_arn
}