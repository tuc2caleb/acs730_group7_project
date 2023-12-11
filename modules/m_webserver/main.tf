#----------------------------------------------------------
# ACS730 - Week 3 - Terraform Introduction
#
# Build EC2 Instances
#
#----------------------------------------------------------
#  Define the provider


provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "public_subnet" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "acs-730-assignment"            // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                     // Region where bucket created
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "private_subnet" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "acs-730-assignment"            // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                     // Region where bucket created
  }
}



# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally


locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

#public subnet 1 vm1 webserver with user data installation
resource "aws_instance" "public_webservers_vm1" {

  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.public_web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install_httpd.sh")
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    local.default_tags,
    {
      #"Name" = "${local.name_prefix}-webserver-public"
       "Name" = "${local.name_prefix}-Webserver-1 - Public"
    }
  )
}

#Bastion host in Public Subnet 2
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.public_subnet_ids[1]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion-Host- 2 Public"
    }
  )
}


#Webserver private VM5 and VM6  in Private Subnet 1 and Private Subnet 2

resource "aws_instance" "web_server_private" {
  count = 2
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.private_subnet.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.private_web_sg.id]
  associate_public_ip_address = false
  //user_data                   = file("${path.module}/install_httpd.sh")

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-VM-${count.index + 5} - Private"
    }
  )
}

# deploying webserver 3 and 4 in public subnet 3 and public subnet 4 without user data insatallation
# installation will be done via ansible
resource "aws_instance" "public_webservers_vm3_vm4" {
  count =  2
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.public_subnet_ids[count.index + 2]
  security_groups             = [aws_security_group.public_web_sg.id]
  associate_public_ip_address = true
 # user_data                   = file("${path.module}/install_httpd.sh")
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    local.default_tags,
    {
      #"Name" = "${local.name_prefix}-webserver-public"
       "Name" = "${local.name_prefix}-Webserver-${count.index + 3} - Public"
    }
  )
}
# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = var.prefix
 // public_key = file("${var.prefix}.pub")
 
  public_key = file("${path.module}/${var.prefix}.pub")
}


#Security Group for bastion vm
resource "aws_security_group" "bastion_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id
   
  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg-Bastion"
    }
  )
}

# Security Group for webserver vms in public subnets
resource "aws_security_group" "public_web_sg" {
  name        = "allow_http_ssh for web"
  description = "Allow HTTP and SSH inbound traffic from internet"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    //security_groups = [aws_security_group.bastion_sg.id]
       cidr_blocks      = ["0.0.0.0/0"]
  }
  

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
   // security_groups = [aws_security_group.bastion_sg.id]
      cidr_blocks      = ["0.0.0.0/0"]
  }
  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg-public"
    }
  )
}

//

# Security Group for private vms in private subnets
resource "aws_security_group" "private_web_sg" {
  name        = "allow_http_ssh for private web servers"
  description = "Allow HTTP and SSH inbound traffic from bastion sg"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
       //cidr_blocks      = ["0.0.0.0/0"]
  }
  

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
      //cidr_blocks      = ["0.0.0.0/0"]
  }
  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg-private"
    }
  )
}

# Elastic IP
resource "aws_eip" "static_eip" {
  instance = aws_instance.bastion_host.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}
