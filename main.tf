terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
}
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIARKB35ZMGTJEZGXED"
  secret_key = "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"
}

resource "aws_vpc" "task-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "TaskVPC"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.task-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "task-subnet"
  }
}

resource "aws_security_group" "task_sec" {
  name        = "task-sec-group"
  description = "Allow SSH traffic and web ports"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-port"
  }
}

resource "tls_private_key" "privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ubuntutaskkey"
  public_key = tls_private_key.privatekey.public_key_openssh
}

resource "aws_instance" "task-ubuntu" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.task_sec.id]
}

output "tls_private_key" {
  description = "Public IP address of the EC2 instance"
  value       = tls_private_key.privatekey.private_key_pem
}
