#VPC module creation

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}
#subnet modules
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}
#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "web_app_igw"
  }
}
#Route_Table
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table_association" "pub_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

#Create Security_Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_server_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_server_sg"
  }
}

/*
#Create EC2 server
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] # Canonical official
}
*/

resource "aws_instance" "jenkins_server" {
  ami           = "ami-04daab3fe532b4df4"
  instance_type = "t2.micro"
  #vailability_zone = "ap-south-1a"
  key_name                    = "aws_ec2_key"
  associate_public_ip_address = true
  iam_instance_profile        = "ec2_admin_role"
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups             = ["${aws_security_group.jenkins_sg.id}"]
  tags = {
    Name = "jenkins_server"
  }
  connection {
    type        = "ssh"
    agent       = false
    private_key = file("./aws_ec2_key.pem")
    user        = "ec2-user"
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh",
    ]
  }
}

resource "aws_eip" "elastic_ip" {
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins_server.id
  allocation_id = aws_eip.elastic_ip.id
}


