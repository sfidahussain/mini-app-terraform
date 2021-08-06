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
    subnets = var.subnets.*.id
    security_groups = var.security_groups
    assign_public_ip = false
  }
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  service_registries {
    registry_arn = var.registry_arn
    port = 8080
  }
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
          value = var.aws_dynamodb_table_name
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
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}


// IAM
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

resource "aws_iam_role_policy" "ecs-task-role-policy" {
  name = "ecs-dynamo"
  role = aws_iam_role.ecs_task_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem",
        ]
        Effect   = "Allow"
        Resource = var.aws_dynamodb_table_arn
      },
    ]
  })
}