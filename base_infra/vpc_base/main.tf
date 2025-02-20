# Create a VPC
resource "aws_vpc" "ac_shopping_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.vpc_name}" })
}

# Create an internet gateway
resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.ac_shopping_vpc.id
  tags   = merge(var.tags, { Name = "public_internet_gateway" })
}

# Create a public subnet
resource "aws_subnet" "ac_shopping_public_subnet" {
  vpc_id                  = aws_vpc.ac_shopping_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
  tags                    = merge(var.tags, { Name = "public_subnet" })
}

# Create a private subnet
resource "aws_subnet" "ac_shopping_private_subnet" {
  vpc_id            = aws_vpc.ac_shopping_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2a"
  tags              = merge(var.tags, { Name = "private_subnet" })
}

# Create a private subnet
resource "aws_subnet" "ac_shopping_private_subnet_2" {
  vpc_id            = aws_vpc.ac_shopping_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-2b"
  tags              = merge(var.tags, { Name = "private_subnet_2" })
}

# Create a private subnet
resource "aws_subnet" "ac_shopping_private_subnet_3" {
  vpc_id            = aws_vpc.ac_shopping_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-southeast-2c"
  tags              = merge(var.tags, { Name = "private_subnet_3" })
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ac_shopping_vpc.id
  tags   = merge(var.tags, { Name = "public_route_table" })
}

# Create a route to the internet gateway for the public subnet
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public_internet_gateway.id
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.ac_shopping_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
