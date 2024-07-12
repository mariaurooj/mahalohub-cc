terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "SG" {
  source               = "../../module/SG"
  sg                   = var.sg
  prefix               = var.prefix
  environment          = var.environment
}
module "Cloudwatch" {
  source               = "../../module/Cloudwatch "
  prefix               = var.prefix
  environment          = var.environment
}
module "ECS" {
  ecs                  = var.ecs
  source               = "../../module/ECS"
  sg_id                = module.SG.sg_id
  prefix               = var.prefix
  environment          = var.environment
  aws_alb_target_group = module.ALB.aws_alb_target_group
  aws_lb_target_group = module.ALB.aws_lb_target_group

}

module "ALB" {
  source              = "../../module/ALB"
  alb                 = var.alb
  sg_id               = module.SG.sg_id
  prefix              = var.prefix
  ecs_service         = module.ECS.ecs_service
  environment         = var.environment

}
module "ASG" {
  source                      = "../../module/ASG"
  asg                         = var.asg
  cluster_name                = module.ECS.ecs_cluster
  sg_id                       = module.SG.sg_id
  prefix                      = var.prefix
  environment                 = var.environment
}

