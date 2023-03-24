output "ec2_global_ips" {
  value = aws_instance.sonarqube_ec2.*.public_ip
}