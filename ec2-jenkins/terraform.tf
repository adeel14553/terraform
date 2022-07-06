# Provider can be any vendor depend on client google,azure etc
provider "aws" {
  region = "us-east-1"
  access_key = "xxx"
  secret_key = "xxx"
}

# SG to allow port 22 443 80
resource "aws_security_group" "tfsgrule" {
  name        = "for-Jenkins-servers"
  description = "Allow traffic"
  # vpc_id = aws_vpc
  ingress {
    description      = "tcp traffic from vpc"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "https traffic from vpc"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh traffic from vpc"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "via terraform"
  }
}

# create ubuntu server and install jenkins
resource "aws_instance" "jenkinServers" {
  ami = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "keyOnMurtazaPCDocs"
  security_groups = [ "for-Jenkins-servers" ]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              wget -O /etc/yum.repos.d/jenkins.repo \
                  https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum upgrade -y
              amazon-linux-extras install java-openjdk11 -y
              yum install jenkins -y
              systemctl start jenkins
              systemctl enable jenkins
              EOF
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}