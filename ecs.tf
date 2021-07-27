resource "aws_ecs_cluster" "cluster" {
  name = "fargate-adt"
}

resource "aws_ecs_task_definition" "task_fe" {
  family = "fe"
  container_definitions = jsonencode([
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol: "tcp"
        }
      ]
      logConfiguration = {
        logDriver: "awslogs",
        options:{
          awslogs-group:"/ecs/aws-ecs-getting-started",
          awslogs-region:"us-east-1",
          awslogs-stream-prefix:"awslogs-fe"
        }
      },
    }
  ])
  requires_compatibilities = 'FARGATE'
  cpu = 256
  memory = 512
  execution_role_arn = "arn:aws:iam::895472411301:role/ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "task_be" {
  family = "fe"
  container_definitions = jsonencode([
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol: "tcp"
        }
      ]
      logConfiguration = {
        logDriver: "awslogs",
        options:{
          awslogs-group:"/ecs/aws-ecs-getting-started",
          awslogs-region:"us-east-1",
          awslogs-stream-prefix:"awslogs-fe"
        }
      },
    }
  ])
  requires_compatibilities = 'FARGATE'
  cpu = 256
  memory = 512
  execution_role_arn = "arn:aws:iam::895472411301:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "fe-service" {
  name            = "fe-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_fe.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.elb.arn
    container_name   = "mongo"
    container_port   = 8080
  }
}

resource "aws_ecs_service" "be-service" {
  name            = "fe-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_fe.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.elb.arn
    container_name   = "mongo"
    container_port   = 8080
  }
}