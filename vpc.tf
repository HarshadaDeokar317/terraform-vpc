
variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

 
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  

}



variable "access_key" {
  default = "AKIA2M3VIEP5XTQAZWFN"
}

variable "secret_key" {
  default = "8eiNxu+FUyxTR0i9j2ph8pZrHBjJs50KDcW1shFR"
}



data "aws_availability_zones" "available" {}

locals {
  cluster_name = "test-cluster-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "test-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

   private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

