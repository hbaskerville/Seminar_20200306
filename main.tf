terraform {
  required_version = "~> 0.12"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}



# Web Security Group
resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Web Sercuriy Group"
  vpc_id      = aws_vpc.playground.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8200
    to_port     = 8200
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}


# VPC
resource "aws_vpc" "playground" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.playground.id
  count             = length(var.availability_zones)
  cidr_block        = var.pubic_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.public_subnet_name}-${count.index}"
  }
}

# EIP
resource "aws_eip" "web_eip" {
  count    = var.web_instance_count
  instance = aws_instance.web_ec2.*.id[count.index]
  vpc      = true
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.playground.id

}

# RouteTable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.playground.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public"
  }
}

# SubnetRouteTableAssociation
resource "aws_route_table_association" "public" {
  count          = length(var.pubic_subnets_cidr)
  subnet_id      = aws_subnet.public.*.id[0]
  route_table_id = aws_route_table.public.id
}

# NatGateway
resource "aws_nat_gateway" "nat" {
  count         = 1
  subnet_id     = aws_subnet.public.*.id[0]
  allocation_id = aws_eip.nat.id
}

resource "aws_instance" "web_ec2" {
  ami   = var.ami
  count = var.web_instance_count
  tags = merge(var.tags, map(
    "Name", "${var.web_instance_name}-${count.index}",
    "TTL", "270h"
  ))
  instance_type = var.web_instance_type
  vpc_security_group_ids = [
  aws_security_group.web_security_group.id]
  subnet_id                   = aws_subnet.public.*.id[0]
  associate_public_ip_address = true
  key_name      = "${aws_key_pair.auth.id}"

  user_data = <<-EOF
IyEvYmluL2Jhc2gNCg0KZWNobyAiZXhwb3J0IFZBVUxUX0FERFI9J2h0dHA6Ly8wLjAuMC4wOjgy
MDAnIiA+PiAvZXRjL3Byb2ZpbGUNCg0KY2F0ID4gL29wdC92YXVsdC9jb25maWcvdmF1bHQtY29u
ZmlnLmhjbCA8PEVPRg0Kc3RvcmFnZSAiZmlsZSIgew0KICAgcGF0aCA9ICIvb3B0L3ZhdWx0L2Rh
dGEiDQp9DQoNCmxpc3RlbmVyICJ0Y3AiIHsNCiAgYWRkcmVzcyAgICAgPSAiMC4wLjAuMDo4MjAw
Ig0KICB0bHNfZGlzYWJsZSA9IDENCn0NCg0KdWkgPSB0cnVlDQpFT0YNCg0KZXhwb3J0IFZBVUxU
X0FERFI9J2h0dHA6Ly8wLjAuMC4wOjgyMDAnDQojL29wdC92YXVsdC9iaW4vdmF1bHQgc2VydmVy
IC1jb25maWcgL29wdC92YXVsdC9jb25maWcvdmF1bHQtY29uZmlnLmhjbCA+IC90bXAvdmF1bHQu
bG9nIDI+JjEgJg0KL29wdC92YXVsdC9iaW4vdmF1bHQgc2VydmVyIC1jb25maWcgL29wdC92YXVs
dC9jb25maWcvdmF1bHQtY29uZmlnLmhjbCAmDQpzbGVlcCAzMA0KL29wdC92YXVsdC9iaW4vdmF1
bHQgb3BlcmF0b3IgaW5pdCA+IC90bXAvdmF1bHQubG9nIDI+JjENCnNsZWVwIDMNCg0KY291bnQ9
MA0KY2F0IC90bXAvdmF1bHQubG9nIHwgd2hpbGUgcmVhZCBsaW5lDQpkbw0KICBpZiBbWyAkbGlu
ZSA9fiAiVW5zZWFsIEtleSAiICBdXTsgdGhlbg0KICAgIGVjaG8gJGxpbmUgPj4gL3RtcC92YXVs
dC5sb2cgDQoNCiAgICAvb3B0L3ZhdWx0L2Jpbi92YXVsdCBvcGVyYXRvciB1bnNlYWwgJHtsaW5l
IyMqIH0gPj4gL3RtcC92YXVsdC5sb2cgMj4mMQ0KDQogICAgY291bnQ9YGV4cHIgJGNvdW50ICsg
MWANCglzbGVlcCAxDQogICAgaWYgWyAkY291bnQgLWVxIDMgXTsgdGhlbg0KICAgICAgZXhpdCAw
DQogICAgZmkNCiAgZmkNCmRvbmUNCg==
EOF
}

resource "aws_alb" "web_alb" {
  name            = "web-alb"
  internal        = false
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.web_security_group.id]
}

resource "aws_alb_target_group" "web_tg" {
  name_prefix     = "web-tg"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = aws_vpc.playground.id

  health_check {
    protocol = "HTTP"
  }
}

resource "aws_alb_target_group_attachment" "alb_attach_tg_web" {
  count            = var.web_instance_count
  target_group_arn = aws_alb_target_group.web_tg.arn
  target_id        = aws_instance.web_ec2.*.id[count.index]
  port             = 8200
}

# Listener for HTTP/HTTPS
resource "aws_alb_listener" "http_web" {
  load_balancer_arn = aws_alb.web_alb.arn
  port              = 8200
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web_tg.arn
  }
}

# Key pair
resource "aws_key_pair" "auth" {
  key_name   = "tf-key"
  public_key = var.public_key
}
