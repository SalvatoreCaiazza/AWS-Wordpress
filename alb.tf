module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  vpc_id          = module.vpc.vpc_id
  name            = "wp-alb-sg"
  use_name_prefix = false
  description     = "Access to public Application Load Balancer"

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.16.0"

  name               = "wp-public-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.this_security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "wp-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled = true
        path    = "/"
        matcher = "200,302"
      }
    }
  ]

}