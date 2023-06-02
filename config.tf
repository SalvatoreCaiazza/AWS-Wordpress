provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "Test"
      Owner       = "Salvatore Caiazza"
      Project     = "ecs_wordpress"

      
    }
  }

}

#terraform {
#  #required_version = "= 1.4.5"
#  required_version= "1.4.5"
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "4.60.0"
#    }
#  }
#}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}