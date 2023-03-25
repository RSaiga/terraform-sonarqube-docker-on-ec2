variable "key_name" {
  default = "sonarqube-keypair"
}

resource "tls_private_key" "sonarqube_private_key" {
  algorithm = "ED25519"
}

locals {
  public_key_file  = "./${var.key_name}.id_ed25519.pub"
  private_key_file = "./${var.key_name}.id_ed25519"
}

resource "local_file" "sonarqube_private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.sonarqube_private_key.private_key_openssh
}

resource "aws_key_pair" "sonarqube_keypair" {
  key_name   = var.key_name
  public_key = trimspace(tls_private_key.sonarqube_private_key.public_key_openssh)
}

data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "sonarqube_ec2" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.sonarqube-security-group.id]
  subnet_id                   = aws_subnet.sonarqube-subnet.id
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  root_block_device {
    volume_type = "gp2"
    volume_size = 16
  }
  user_data = file("./setup.sh")

  tags = {
    Name = "sonarqube-ec2"
  }
}