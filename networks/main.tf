# Module to deploy basic networking 
module "vpc-dev" {
  source = "../../modules/aws_network"
  # source             = "git@github.com:rkhalid7890/aws_network.git"
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  public_cidr_blocks  = var.public_subnet_cidrs
  private_cidr_blocks = var.private_subnet_cidrs
  prefix              = var.prefix
  default_tags        = var.default_tags
}
