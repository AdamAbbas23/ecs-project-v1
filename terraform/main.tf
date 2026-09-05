terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

module "vpc" {
  source = "./modules/vpc"
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
}
module "aws_ecr_repository" {
  source = "./modules/ecr"
}
module "iam" {
  source = "./modules/iam"
}
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id 
}
module "acm" {
  source = "./modules/acm"
  domain_name = var.domain_name
}
module "alb" {
  source = "./modules/alb"
  alb_sg_id = module.security_groups.alb_sg_id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id = module.vpc.vpc_id
}
module "ecs" {
  source = "./modules/ecs"
  ecr_image_url = "${module.aws_ecr_repository.repository_url}:latest"
  private_subnet_ids = module.vpc.private_subnet_ids
  execution_role_arn = module.iam.execution_role_arn
  ecs_tasks_sg_id = module.security_groups.ecs_tasks_sg_id
  target_group_arn = module.alb.target_group_arn
}
module "route53" {
  source = "./modules/route53"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  zone_id = var.zone_id
  hosted_zone_id = var.zone_id
}
