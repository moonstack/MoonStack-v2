provider "aws" {
  region = var.ec2_region
}

resource "aws_security_group" "moon" {
  name        = "MoonStack"
  description = "MoonStack Honeypot"
  vpc_id      = var.ec2_vpc_id
  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 64294
    to_port     = 64294
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
  }
  ingress {
    from_port   = 64295
    to_port     = 64295
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
  }
  ingress {
    from_port   = 64297
    to_port     = 64297
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MoonStack"
  }
}

resource "aws_instance" "moon" {
  ami           = var.ec2_ami[var.ec2_region]
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_ssh_key_name
  subnet_id     = var.ec2_subnet_id
  tags = {
    Name = "MoonStack Honeypot"
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }
  user_data              = "${file("../cloud-init.yaml")}    content: ${base64encode(file("../moon.conf"))}"
  vpc_security_group_ids = [aws_security_group.moon.id]
  associate_public_ip_address = true
}
