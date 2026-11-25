#---------------vpc----------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "env"
  }
}
#--------------internet getwy-------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "env-igw"
  }
}
#---------------pubsubnet--------------------
resource "aws_subnet" "pub" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.40.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub-subenv"
  }
}

#-----------RT-for public sub-------------------------
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
#----------link subnet to rt---------------------
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt.id
}
#-------------eib----------------------
resource "aws_eip" "lb" {
  domain = "vpc"
}
#------------nat getway---------------
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.pub.id

  tags = {
    Name = "wnv-ngw"
  }

  depends_on = [aws_internet_gateway.gw]
}
#---------------prvsubnet--------------------
resource "aws_subnet" "prv" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.40.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "priv-subenv"
  }
}
#-----------RT-for private sub-------------------------
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}
#----------link subnet to rt2---------------------
resource "aws_route_table_association" "example1" {
  subnet_id      = aws_subnet.prv.id
  route_table_id = aws_route_table.rt1.id
}
#---------------s3 endpoint-------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.rt1.id]

  tags = {
    Environment = "test"
  }
}