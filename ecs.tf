module "ecs_task_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  vpc_id          = module.vpc.vpc_id
  name            = "wp-ecs-task-sg"
  use_name_prefix = false
  description     = "Access to public Application Load Balancer"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "Connections and Health Checks from Application Load Balancer"
      source_security_group_id = module.alb_sg.this_security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

}

resource "aws_ecs_cluster" "wp" {
  name = "wp-fargate-cluster"
}

resource "aws_ecs_service" "wp" {
  name    = "wp-fargate-service"
  cluster = aws_ecs_cluster.wp.id

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  task_definition = aws_ecs_task_definition.wordpress.arn

  desired_count = 2

  network_configuration {
    security_groups = [
      module.efs_sg.this_security_group_id,
      module.ecs_task_sg.this_security_group_id
    ]
    subnets = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0] 
    container_name   = "wordpress"
    container_port   = 80
  }


  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "wp-service" {
  min_capacity       = 1
  max_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.wp.name}/${aws_ecs_service.wp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "wp-service" {
  name               = "wp.fargate-service-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.wp-service.id
  scalable_dimension = aws_appautoscaling_target.wp-service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.wp-service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wordpress"
  execution_role_arn       = module.ecs_task_execution_role.this_iam_role_arn
  task_role_arn            = module.ecs_task_role.this_iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

  container_definitions = templatefile(
    "wordpress_definition.json",
    {
      db_user         = var.username,
      db_password     = aws_ssm_parameter.mysql_db_password.arn,
      db_host         = module.db.db_instance_endpoint,
      wordpress_db_name = module.db.db_instance_name,
      container_image = var.container_image,
      container_name  = "wordpress",
      container_port  = 80,
      log_group       = aws_cloudwatch_log_group.wordpress.name,
      region          = var.region
    }
  )

  volume {
    name = "efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.persistent_data.id
    }
  }
}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/wordpress/wp-task"
  retention_in_days = 7
}


###SG per accesso al DB
resource "aws_security_group_rule" "grant_access_to_db_from_service" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.ecs_task_sg.this_security_group_id
  security_group_id        = aws_security_group.rds.id
}