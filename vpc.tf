resource "aws_vpc" "sonarqube" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sonarqube-vpc"
  }
}

resource "aws_subnet" "sonarqube-subnet" {
  vpc_id            = aws_vpc.sonarqube.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sonarqube-subnet"
  }
}

resource "aws_internet_gateway" "sonarqube" {
  vpc_id = aws_vpc.sonarqube.id

  tags = {
    Name = "sonarqube-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sonarqube.id

  tags = {
    Name = "sonarqube-route-table"
  }
}

resource "aws_route" "sonarqube" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.sonarqube.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "sonarqube" {
  subnet_id      = aws_subnet.sonarqube-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sonarqube-security-group" {
  vpc_id = aws_vpc.sonarqube.id
  name   = "sonarqube-security-group"

  tags = {
    Name = "sonarqube-security-group"
  }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.sonarqube-security-group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.sonarqube-security-group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.sonarqube-security-group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}