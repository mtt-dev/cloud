provider "aws" {
  region = "eu-central-1"
}

variable "ami_id" {
  description = "The AMI-ID from the previous Packer run"
}

resource "aws_instance" "testbed" {
  instance_type   = "t2.micro"
  ami             = var.ami_id	
  security_groups = ["${aws_security_group.testbed_sg.name}"]
}

resource "aws_security_group" "testbed_sg" {
  name = "testbed_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ipv4" {
  value = aws_instance.testbed.public_ip
}

output "public_dns" {
  value = aws_instance.testbed.public_dns
}
