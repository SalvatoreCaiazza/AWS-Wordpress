#VPC
name               = "wp-vpc"
cidr               = "10.0.0.0/16"
single_nat_gateway = true

#subnets
private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
database_subnets = ["10.0.103.0/24", "10.0.104.0/24"]

#region
region = "eu-west-1"

##############################################RDS
allocated_storage = 10
engine = "mysql"
engine_version= "8.0"
family= "mysql8.0"
db_name = "wordpressdb"
username = "wordpressdb"
db_port = 3306
major_engine_version = "8.0"
snapshot = true
instance_class = "db.t4g.small"

##############################################ECS
container_image = "wordpress:6.0"
