variable "security_groups" {
  description = "Comma separated list of security groups"
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "registry_arn" {
  description = "ARN of Service Registry"
}

variable "aws_dynamodb_table_name" {
  description = "Name of DynamoDB PetStore table"
}

variable "aws_dynamodb_table_arn" {
  description = "ARN of DynamoDB PetStore table"
}