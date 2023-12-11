# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-VPC"
    }
  )
}


# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_subnet" {
//count = var.env == "prod" ? 0 : length(var.public_cidr_blocks)
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-subnet-${count.index + 1 }"
    }
  )
}

# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-private-subnet-${count.index + 1 }"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
//count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-igw"
    }
  )
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "RouteTable_public_subnets" {
//count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.name_prefix}-route-public-subnets"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_routes" {
//count = var.env == "prod" ? 0 :  length(aws_subnet.public_subnet[*].id)
  count = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.RouteTable_public_subnets.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}



# # Create NAT Gateway
# resource "aws_nat_gateway" "nat" {
# count = var.env == "prod" ? 0 : 1
#   allocation_id = aws_eip.nat[0].id
# subnet_id     = aws_subnet.public_subnet[1].id
 
#   tags = merge(local.default_tags,
#     {
#       "Name" = "${var.prefix}-nat"
#     }
#   )
# }
# # Create Elastic IP for NAT Gateway
# resource "aws_eip" "nat" {
# #vpc_id = aws_vpc.main.id
# count = var.env == "prod" ? 0 : 1
#   depends_on = [aws_internet_gateway.igw]

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${var.prefix}-nat-eip"
#     }
#   )
# }


# //Create Private Route Table 1 for dev which will have route to nat gateway
# resource "aws_route_table" "RouteTable1_private_subnets" {
# //count = var.env == "prod" ? 0 : length(var.public_cidr_blocks)
# count = var.env == "prod" ? 0 : length(aws_subnet.private_subnet)
#   vpc_id = aws_vpc.main.id
# route {
#     cidr_block = "0.0.0.0/0"
#   //  
#   //nat_gateway_id = aws_nat_gateway.nat[0].id
#   }
#   tags = merge(local.default_tags,
#     {
#       "Name" = "${var.prefix}-private-route-table1"
#     }
#   )
# }

# # # Associate private subnets with the custom route table
# resource "aws_route_table_association" "private_routes1" {
# //count = var.env == "prod" ? 0 : length(aws_subnet.private_subnet[*].id)
# count          = length(aws_subnet.private_subnet[*].id)
# // route_table_id = aws_route_table.RouteTable1_private_subnets[0].id
 
#   route_table_id = aws_route_table.RouteTable1_private_subnets.id
#   subnet_id      = aws_subnet.private_subnet[count.index].id
# }

