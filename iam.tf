

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    sid = "AmazonECSTaskExecutionRolePolicy"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

module "ecs_task_execution_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.16.0"

  name        = "wp-ecs-task-execution"
  description = "Amazon ECS Task Execution Role Policy"
  policy      = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.16.0"

  role_name         = "wp-ecs-task-execution-role"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.ecs_task_execution_policy.arn
  ]

  number_of_custom_role_policy_arns = 1
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    sid = "AmazonECSTaskExecutionRolePolicy"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [aws_efs_file_system.persistent_data.arn]
  }
}

module "ecs_task_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.16.0"

  name        = "wp-ecs-task"
  description = "Amazon ECS Task Role Policy"
  policy      = data.aws_iam_policy_document.ecs_task_policy.json
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.16.0"

  role_name         = "wp-ecs-task-role"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.ecs_task_policy.arn
  ]

  number_of_custom_role_policy_arns = 1
}