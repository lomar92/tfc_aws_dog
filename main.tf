#Main Config 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=3.42.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "DogApp" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    name        = "${var.prefix}-vpc-${var.region}"
    environment = "DogProduction"
  }
}

resource "aws_subnet" "DogApp" {
  vpc_id     = aws_vpc.DogApp.id
  cidr_block = var.subnet_prefix

  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource "aws_security_group" "DogApp" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.DogApp.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_internet_gateway" "DogApp" {
  vpc_id = aws_vpc.DogApp.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "DogApp" {
  vpc_id = aws_vpc.DogApp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DogApp.id
  }
}

resource "aws_route_table_association" "DogApp" {
  subnet_id      = aws_subnet.DogApp.id
  route_table_id = aws_route_table.DogApp.id
}

resource "aws_eip" "DogApp" {
  instance = aws_instance.DogApp.id
  vpc      = true
}

resource "aws_eip_association" "DogApp" {
  instance_id   = aws_instance.DogApp.id
  allocation_id = aws_eip.DogApp.id
}


resource "aws_instance" "DogApp" {
  ami                         = "ami-09399ab07dc45568b"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.DogApp.id
  vpc_security_group_ids      = [aws_security_group.DogApp.id]

  tags = {
    Name = "${var.prefix}-DogApp-instance"
  }
}
