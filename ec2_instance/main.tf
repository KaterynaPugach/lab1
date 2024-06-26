terraform {
backend "s3" {
	bucket         = "puhach-s3-backend"
	key            = "terraform.tfstate"
	region         = "us-east-1"
	dynamodb_table = "puhachbackend"
  }
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

# Configure AWS provider and creds
provider "aws" {
	region = "us-east-1"
	shared_config_files = ["../s3_website/config"]
	shared_credentials_files = ["../s3_website/credentials"]
	profile = "default"
}


# Get the latest Amazon Linux ami id
data "aws_ami" "amazon_linux" {
	most_recent = true
	filter {
		name = "name"
		values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
	}
	owners = ["amazon"]
}

# Create ec2 instance
resource "aws_instance" "web" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = "t2.micro"
	key_name = "PuhachWebServer"
	vpc_security_group_ids = [aws_security_group.web_sg.id]
	tags = { "Name" = "New webserver"
}

user_data = <<-EOF
	#!/bin/bash
	sudo yum update -y
	sudo yum install httpd -y
	sudo systemctl start httpd
	sudo systemctl enable httpd
	echo "<html><h1>Your webserv works! ІМІм-23-2 Катерина Пугач</h1></html>" > /var/www/html/index.html
	EOF
}
# Security group
resource "aws_security_group" "web_sg" {
	name = "Ec2 instance sg"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["159.224.180.55/32"]

	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["159.224.180.55/32"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}
output "website_endpoint" {
	value = aws_instance.web.public_dns
}
