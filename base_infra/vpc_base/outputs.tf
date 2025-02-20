output "vpc_id" {
  value = aws_vpc.ac_shopping_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.ac_shopping_public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.ac_shopping_private_subnet.id
}

