terraform {
  backend "remote" {
    organization = "<<YOUR TERRAFORM ENTERPRISE ORGANIZATION>>"

    workspaces {
      name = "<<ORGANIZATION>>"
    }
  }
}

provider "aws" {
  profile = "<<AWS CLI PROFILE>>"
  region  = "us-east-1"
  version = "= 2.16.0"
}

resource "aws_vpc" "multicloud" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "multicloud"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = "${aws_vpc.multicloud.id}"

  tags = {
    Name = "Main IGW"
  }
}

#public RT
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.multicloud.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main_gw.id}"
  }

  tags = {
    Name = "Public Route"
  }
}

resource "aws_subnet" "internal" {
  vpc_id            = "${aws_vpc.multicloud.id}"
  cidr_block        = "10.3.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "internal"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.multicloud.id}"
  cidr_block        = "10.3.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public-route" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# look for the latest CentOS AMI
data "aws_ami" "centos-linux-instance" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["410186602215"]
}

resource "aws_security_group" "allow-ssh-http" {
  name        = "multicloud-allow-ssh-http"
  description = "Main Instance traffic"
  vpc_id      = "${aws_vpc.multicloud.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from Home"
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from everywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound traffic"
  }

  tags = {
    Name = "multicloud-allow-ssh-http"
  }
}

# create instance in public subnet
resource "aws_instance" "web-server" {
  # ami                         = "${data.aws_ami.centos-linux-instance.id}"
  ami = "ami-a8d369c0"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.allow-ssh-http.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  key_name                    = "<<EC2 KEY TO USE>>"
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum  update 
                sudo yum  install httpd -y 
                echo '<!doctype html><html><body><h1>Hello Multicloud 2019 from AWS!</h1></body></html>' | sudo tee /var/www/html/index.html 
                sudo systemctl start httpd
                EOF

  tags = {
    Name = "Web Instance"
  }
}
