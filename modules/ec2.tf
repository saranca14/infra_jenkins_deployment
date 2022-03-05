resource "aws_instance" "ec2_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "sample_instance"
  }
}