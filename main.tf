terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}

provider "aws" {
  #Configuration options
  region = "us-east-1"
}

resource "aws_vpc" "riya_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "riya_vpc"
  }
}

resource "aws_subnet" "riya_subnet" {
  vpc_id     = aws_vpc.riya_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "riya_subnet"
  }
}

resource "aws_internet_gateway" "riya_igw" {
  vpc_id = aws_vpc.riya_vpc.id
}

resource "aws_route_table" "riya_route_table" {
  vpc_id = aws_vpc.riya_vpc.id
}

resource "aws_route" "riya_routes" {
  route_table_id         = aws_route_table.riya_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.riya_igw.id
}

resource "aws_route_table_association" "riya_rt_association" {
  route_table_id = aws_route_table.riya_route_table.id
  subnet_id      = aws_subnet.riya_subnet.id
}

resource "aws_security_group" "riya_sg" {
  name        = "Allow_ALL"
  vpc_id      = aws_vpc.riya_vpc.id
  description = "Allow_All_traffic"
  ingress {
    description = "Allow_ALL"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow_ALL"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "riya_ec2" {
  ami                         = "ami-012967cc5a8c9f891"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.riya_subnet.id
  key_name                    = "ec2_keypair"
  vpc_security_group_ids      = [aws_security_group.riya_sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1> Welcome to AWS Terraform!!!. This Ec2 isntance is created using Terraform </h1>" > /var/www/html/index.html
  EOF
  tags = {
    Name = "Apache Webserver"
  }
}
