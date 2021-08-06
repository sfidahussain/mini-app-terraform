resource "aws_security_group" "allow_fargate" {
  name        = "Container Security Group"
  description = "Access to the Fargate containers"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      self             = true
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids   = []
      security_groups  = []
    }
  ]

  egress = [
    {
      description      = "Allow all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "Allow Fargate"
  }
}

output "allow_fargate" {
  value = aws_security_group.allow_fargate.id
}