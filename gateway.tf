resource "aws_apigatewayv2_api" "petstore_api" {
  name          = "petstore"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "petstore_stage" {
  api_id = aws_apigatewayv2_api.petstore_api.id
  name   = "test"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.petstore_api.id
  route_key = "GET /petstore/pets/{petId}"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.petstore_api.id
  integration_type = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.link.id

  integration_method = "ANY"
  integration_uri    = aws_service_discovery_service.service.arn  // AWS CloudMap Service
}

resource "aws_apigatewayv2_route" "put" {
  api_id    = aws_apigatewayv2_api.petstore_api.id
  route_key = "PUT /petstore/pets/{petId}"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorizer_id = aws_apigatewayv2_authorizer.put_authorizer.id
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.101.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.102.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Private Subnet 3"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public Subnet 3"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_apigatewayv2_vpc_link" "link" {
  name               = "vpc_link"
  security_group_ids = [aws_security_group.allow_fargate.id]
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Usage = "example"
  }
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = "service"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "service" {
  name = "pets.petstore"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.namespace.id

    dns_records {
      ttl  = 60
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_security_group" "allow_fargate" {
  name        = "Container Security Group"
  description = "Access to the Fargate containers"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = -1
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

resource "aws_ecs_cluster" "cluster" {
  name = "cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "service" {
  name            = "petstore"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  network_configuration {
    subnets = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
    security_groups = [aws_security_group.allow_fargate.id]
    assign_public_ip = false
  }
//  iam_role        = aws_iam_role.ecs-role.arn
//  depends_on      = [aws_iam_role_policy.ecs-service]
}

resource "aws_iam_role_policy" "ecs-service" {
  name = "ecs-service"
  role = aws_iam_role.ecs-role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:Describe*",
          "ec2:DetachNetworkInterface",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs-role" {
  name = "ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_ecs_task_definition" "task" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "PetstorePets"
      image     = "simonepomata/ecsapi-demo-petstore:latest"
      environment = [
        {
          name = "DynamoDBTable"
          value = aws_dynamodb_table.dynamodb-petstore-table.name
        }
      ]
      portMappings = [{
        hostPort = 8080
        protocol = "tcp"
        containerPort = 8080
      }]
      essential = true
    },
  ])
  cpu       = 256
  memory    = 512
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
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

resource "aws_cognito_user_pool" "pool" {
  name = "mypool"
}

resource "aws_apigatewayv2_authorizer" "put_authorizer" {
  api_id           = aws_apigatewayv2_api.petstore_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "put-authorizer"

  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}