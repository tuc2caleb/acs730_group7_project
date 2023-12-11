# Module to deploy basic networking for terraform1
module "aws_webserver_m" {
  source              = "../../modules/m_webserver"
  env                 = var.env
  instance_type       = var.instance_type
  prefix              = var.prefix
  default_tags        = var.default_tags
}


