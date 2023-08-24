# Create VPC

resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "MoizVPC"
  }
}



# Create Subnets

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.pub_subnet
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}



# Create Internetgateway

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}




resource "aws_route_table" "moiz_public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "Test Public Route Table"
  }
}


resource "aws_route_table_association" "public_rt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.moiz_public_rt.id
}






# Creating Instance

resource "aws_instance" "example" {
  ami           = "ami-0ccabb5f82d4c9af5"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = ["${aws_security_group.moiz_web_sg.id}"]
  key_name               = aws_key_pair.key-tf.key_name

  tags = {
    Name = "Testing Instance"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo su
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

}

resource "aws_security_group" "moiz_web_sg" {
  name        = "moiz_web_sg"
  description = "Allow port 80 from our IPs"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["202.47.39.228/32", "104.50.195.18/32"]
  }
}

