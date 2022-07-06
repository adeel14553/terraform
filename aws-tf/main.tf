# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "Access key"
  secret_key = "Private key"
}

# 1 Create a VPC
resource "aws_vpc" "tfvpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "tf"
  }

}

# 2. Create ig
resource "aws_internet_gateway" "tfgw" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    Name = "tf"
  }
}

# 3. Create custom rt
resource "aws_route_table" "tfrt" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.tfgw.id
  }

  tags = {
    Name = "tf"
  }
}

# 4. Creat subnet
resource "aws_subnet" "tfsub" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf"
  }
}

# 5. associat subnet with rt
resource "aws_route_table_association" "tfrtsubass" {
  subnet_id = aws_subnet.tfsub.id
  route_table_id = aws_route_table.tfrt.id
}

# 6. sg to allow port 22 443 80
resource "aws_security_group" "tfsgrule" {
  name        = "allow_traffic"
  description = "Allow traffic"
  vpc_id      = aws_vpc.tfvpc.id

  ingress {
    description      = "https traffic from vpc"
    from_port        = 443
    to_port          = 443
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
    description      = "https traffic from vpc"
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
    Name = "tf"
  }
}
# 7. creat network interface with ip, there can be many
resource "aws_network_interface" "tfnic" {
  subnet_id       = aws_subnet.tfsub.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.tfsgrule.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}
# 8. assign elastic ip to network interface > the public ip
resource "aws_eip" "tfeip" {
  # instance = aws_instance.web.id
  vpc      = true
  network_interface = aws_network_interface.tfnic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.tfgw]
}

# 9. create ubuntu server and install apache
# resource "aws_instance" "tfubuntu" {
#   ami = ""
#   instance_type = "t2.micro"
#   availability_zone = "us-east-1a"
#   key_name = ""
#   network_interface {
#     device_index = 0
#     network_interface_id = aws_network_interface.tfnic.id
#   }
  
#   user_data = <<-EOF
#               #!/bin/bash
#               sudo apt update -y
#               sudo apt install apache2 -y
#               sudo systemctl start apache2
#               sudo bash -c 'echo hello world > /var/www/html/index.html'
#               EOF
#   tags = {
#     name = "tf"
#   }
# }