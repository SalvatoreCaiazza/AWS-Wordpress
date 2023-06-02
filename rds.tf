module "db" {
  source                 = "terraform-aws-modules/rds/aws"
  identifier             = "rds-wordpress"
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  family                 = var.family
  db_name                = var.db_name
  username               = var.username
  create_random_password = true
  port                   = var.db_port
  major_engine_version   = var.major_engine_version
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = var.snapshot
  create_db_subnet_group = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow mysql port"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ssm_parameter" "mysql_db_password" {
  name      = "rds-password"
  type      = "SecureString"
  value     = module.db.db_instance_password
  overwrite = true
}

