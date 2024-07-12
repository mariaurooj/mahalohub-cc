resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-${var.prefix}-closedcaptioning"
}
resource "aws_ecs_task_definition" "service" {
  family                   = "${var.environment}-${var.prefix}-closedcaptioning"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge" 
  execution_role_arn = "arn:aws:iam::383798767483:role/dev-mahalohub-ecs-task-role"
  task_role_arn      = "arn:aws:iam::383798767483:role/dev-mahalohub-ecs-task-role"
  container_definitions = jsonencode([
    {
      name      = "${var.environment}-${var.prefix}-closedcaptioning"
      cpu       = var.ecs.container_def.cpu
      memory    = var.ecs.container_def.memory
      image     = var.ecs.container_def.image
      essential = var.ecs.container_def.essential
      logConfiguration = {
                logDriver = "awslogs",
                options = {
                    awslogs-group = "/ecs/dev/mahalohub/closedcaptioning"
                    awslogs-region = "us-east-1"
                    awslogs-create-group =  "true"
                    awslogs-stream-prefix = "ecs/${var.environment}-${var.prefix}-closedcaptioning"
                }
      }
      portMappings = [
        {
          containerPort = var.ecs.portmappings.containerport
          hostPort      = var.ecs.portmappings.hostport
        }
      ]
    },
  ])
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}
resource "aws_ecs_service" "service" {
  name            = "${var.environment}-${var.prefix}-closedcaptioning"
  launch_type     = "EC2"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.ecs.desired_count
  load_balancer {
    target_group_arn = var.aws_alb_target_group
    container_name   = "${var.environment}-${var.prefix}-closedcaptioning"
    container_port   = var.ecs.portmappings.containerport
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}

resource "aws_efs_file_system" "this" {
  encrypted      = false
  performance_mode = "generalPurpose"
  throughput_mode = "elastic"
   lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "efs-monitoring"
  }
}
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "mount_subnet_1" {
  file_system_id = aws_efs_file_system.this.id
  security_groups = [var.sg_id]
  subnet_id      = "subnet-0e125d3fd64415646"  # First subnet ID
}

resource "aws_efs_mount_target" "mount_subnet_2" {
  file_system_id = aws_efs_file_system.this.id
  security_groups = [var.sg_id]
  subnet_id      = "subnet-035e3c258a22c8be8"  # Second subnet ID
}

resource "aws_ecs_task_definition" "Service" {
  family                   = "${var.environment}-${var.prefix}-monitoring"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                   = "1024" 
  memory                = "2048"
  execution_role_arn = "arn:aws:iam::383798767483:role/dev-mahalohub-ecs-task-role"
  task_role_arn      = "arn:aws:iam::383798767483:role/dev-mahalohub-ecs-task-role"
  volume {
    name = "efs-monitoring"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.this.id 
      root_directory          = "/"

      }    
  }
  container_definitions = jsonencode([
    {
      name      = "${var.environment}-${var.prefix}-monitoring"
      cpu       = 1024
      memory    = 2048
      image     = "383798767483.dkr.ecr.us-east-1.amazonaws.com/dev-monitoring:latest"
      essential = var.ecs.container_def.essential
      logConfiguration = {
                logDriver = "awslogs",
                options = {
                    awslogs-group = "/ecs/grafana"
                    awslogs-region = "us-east-1"
                    awslogs-create-group =  "true"
                    awslogs-stream-prefix = "dashboard"
                }
      }
      mountPoints = [
        {
          sourceVolume = "efs-monitoring"
          containerPath = "/data"
          readOnly = false
        }
      ]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "Service" {
  name            = "${var.environment}-${var.prefix}-monitoring"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.Service.arn
  desired_count   = var.ecs.desired_count
  enable_execute_command             = true
  network_configuration {
    subnets         = ["subnet-035e3c258a22c8be8", "subnet-0e125d3fd64415646"]
    security_groups = [var.sg_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.aws_lb_target_group
    container_name   = "${var.environment}-${var.prefix}-monitoring"
    container_port   = var.ecs.portmappings.containerport1
  }
}
/*
#############################test
resource "aws_ecs_task_definition" "test" {
  family                   = "test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                   = "256" 
  memory                = "512"
  container_definitions = jsonencode([
    {
      name      = "${var.environment}-${var.prefix}-monitoring"
      cpu       = 256
      memory    = 512
      image     = "nginx:latest"
      essential = var.ecs.container_def.essential
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "test" {
  name            = "test"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.test.arn
  desired_count   = var.ecs.desired_count
  network_configuration {
    subnets         = ["subnet-035e3c258a22c8be8", "subnet-0e125d3fd64415646"]
    security_groups = [var.sg_id]
    assign_public_ip = true
  }
    capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}
*/