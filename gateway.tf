resource "aws_apigatewayv2_api" "petstore_api" {
  name          = "petstore"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "petstore_stage" {
  api_id = aws_apigatewayv2_api.petstore_api.id
  name   = "$default"
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
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.put_authorizer.id
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
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

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.eip_3.id
  subnet_id     = aws_subnet.public_subnet_3.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route_table_private_3" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "route_private_1" {
  route_table_id         = aws_route_table.route_table_private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}


resource "aws_route" "route_private_2" {
  route_table_id         = aws_route_table.route_table_private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

resource "aws_route" "route_private_3" {
  route_table_id         = aws_route_table.route_table_private_3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_3.id
}

resource "aws_route_table_association" "route_table_association_private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.route_table_private_1.id
}

resource "aws_vpc_endpoint_route_table_association" "endpoint_association_private_1" {
  route_table_id = aws_route_table.route_table_private_1.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamo.id
}

resource "aws_route_table_association" "route_table_association_private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.route_table_private_2.id
}

resource "aws_vpc_endpoint_route_table_association" "endpoint_association_private_2" {
  route_table_id = aws_route_table.route_table_private_2.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamo.id
}

resource "aws_route_table_association" "route_table_association_private_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.route_table_private_3.id
}

resource "aws_vpc_endpoint_route_table_association" "endpoint_association_private_3" {
  route_table_id = aws_route_table.route_table_private_3.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamo.id
}

resource "aws_eip" "eip_1" {
  vpc = true
}

resource "aws_eip" "eip_2" {
  vpc = true
}

resource "aws_eip" "eip_3" {
  vpc = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet 2"
  }
  map_public_ip_on_launch = true

}

resource "aws_subnet" "public_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public Subnet 3"
  }
  map_public_ip_on_launch = true

}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
  map_public_ip_on_launch = true

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public.id
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
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  service_registries {
    registry_arn = aws_service_discovery_service.service.arn
    port = 8080
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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
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

resource "aws_vpc_endpoint" "dynamo" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.dynamodb"
}