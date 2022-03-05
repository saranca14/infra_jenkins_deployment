output "ec2_ip" {
  value = aws_instance.jenkins_server.*
}