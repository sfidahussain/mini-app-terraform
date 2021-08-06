
variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default = "demo"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default = "test"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default =  "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  default     = ["10.0.0.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  default     = ["10.0.100.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default = ["us-east-1a"]
}