resource "aws_security_group" "allow_tls" {
  name        = "ADT Default SGs"
  description = "Allow HTTP & HTTPSs inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allowing Port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "ADT ELB Security Group"
  description = "Allow all inbound connections but only from the load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allowing only from SG of load balancer"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_security_group.allow_tls.name]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}